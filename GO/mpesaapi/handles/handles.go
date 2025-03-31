package handles

import (
	"bytes"
	"encoding/base64"
	"encoding/json"
	"fmt"
	"log"
	"mpesa/db"
	"mpesa/models"
	"net/http"
	"time"

	"github.com/gofiber/fiber/v2"
)

// Safaricom API Credentials
var (
	ConsumerKey    = "IipnyUCB5G8vFAH2QVmkgAqiQFhhMgmHHX1jdZukMNlSY33d"
	ConsumerSecret = "zNcEFFKNBVsqR5z5SibNxUfLlX56cmyakcJ31SAWBWPzj4oT5fzvH1jOZkDOS5kt"
	ShortCode      = "174379"
	PassKey        = "bfb279f9aa9bdbcf158e97dd71a467cd2e0c893059b10f78e6b72ada1ed2c919"
	CallbackURL    = "https://mpesaapi.onrender.com/callback"
)

func GetAccessToken() (string, error) {
	auth := base64.StdEncoding.EncodeToString([]byte(ConsumerKey + ":" + ConsumerSecret))

	req, err := http.NewRequest("GET", "https://sandbox.safaricom.co.ke/oauth/v1/generate?grant_type=client_credentials", nil)
	if err != nil {
		log.Println("Error creating access token request:", err)
		return "", err
	}

	req.Header.Set("Authorization", "Basic "+auth)
	req.Header.Set("Content-Type", "application/json")

	client := &http.Client{}
	resp, err := client.Do(req)
	if err != nil {
		log.Println("Error sending access token request:", err)
		return "", err
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return "", fmt.Errorf("failed to get access token: HTTP %d", resp.StatusCode)
	}

	var tokenResponse models.AccessTokenResponse
	if err := json.NewDecoder(resp.Body).Decode(&tokenResponse); err != nil {
		log.Println("Error decoding access token response:", err)
		return "", err
	}

	return tokenResponse.AccessToken, nil
}

func StkPushHandler(c *fiber.Ctx) error {
	var requestData struct {
		PhoneNumber string `json:"phone"`
		Amount      int    `json:"amount"`
	}

	if err := c.BodyParser(&requestData); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "Invalid request"})
	}

	if len(requestData.PhoneNumber) != 12 || requestData.Amount <= 0 {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "Invalid input"})
	}

	accessToken, err := GetAccessToken()
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": "Failed to get access token"})
	}

	timestamp := time.Now().Format("20060102150405")
	password := base64.StdEncoding.EncodeToString([]byte(ShortCode + PassKey + timestamp))

	stkRequest := models.STKPushRequest{
		BusinessShortCode: ShortCode,
		Password:          password,
		Timestamp:         timestamp,
		TransactionType:   "CustomerPayBillOnline",
		Amount:            requestData.Amount,
		PartyA:            requestData.PhoneNumber,
		PartyB:            ShortCode,
		PhoneNumber:       requestData.PhoneNumber,
		CallBackURL:       CallbackURL,
		AccountReference:  "FlutterPayment",
		TransactionDesc:   "Payment from Flutter App",
	}

	jsonData, err := json.Marshal(stkRequest)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": "Failed to encode JSON"})
	}

	req, err := http.NewRequest("POST", "https://sandbox.safaricom.co.ke/mpesa/stkpush/v1/processrequest", bytes.NewBuffer(jsonData))
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": "Failed to create request"})
	}

	req.Header.Set("Authorization", "Bearer "+accessToken)
	req.Header.Set("Content-Type", "application/json")

	client := &http.Client{}
	resp, err := client.Do(req)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": "Failed to send STK Push"})
	}
	defer resp.Body.Close()

	var stkResponse models.STKPushResponse
	if err := json.NewDecoder(resp.Body).Decode(&stkResponse); err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": "Failed to decode STK Push response"})
	}

	payment := models.Payment{
		PhoneNumber: requestData.PhoneNumber,
		Amount:      requestData.Amount,
		CheckoutID:  stkResponse.CheckoutRequestID,
		Status:      "Pending",
	}
	db.Db.Create(&payment)

	return c.JSON(stkResponse)
}

func CallbackHandler(c *fiber.Ctx) error {
	var callbackData map[string]interface{}
	if err := c.BodyParser(&callbackData); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "Invalid callback data"})
	}

	log.Println("Callback Response:", callbackData)

	if body, ok := callbackData["Body"].(map[string]interface{}); ok {
		if stkCallback, ok := body["stkCallback"].(map[string]interface{}); ok {
			if resultCode, ok := stkCallback["ResultCode"].(float64); ok && resultCode == 0 {
				checkoutID := stkCallback["CheckoutRequestID"].(string)
				transactionID := stkCallback["MpesaReceiptNumber"].(string)

				var payment models.Payment
				db.Db.Where("checkout_id = ?", checkoutID).First(&payment)
				payment.TransactionID = transactionID
				payment.Status = "Completed"
				db.Db.Save(&payment)
			} else {
				checkoutID := stkCallback["CheckoutRequestID"].(string)
				var payment models.Payment
				db.Db.Where("checkout_id = ?", checkoutID).First(&payment)
				payment.Status = "Failed"
				db.Db.Save(&payment)
			}
		}
	}

	return c.SendStatus(fiber.StatusOK)
}

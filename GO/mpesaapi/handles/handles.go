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
		AccountReference:  "House Booking",
		TransactionDesc:   "Booking of house",
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



// func CallbackHandler(c *fiber.Ctx) error {
// 	// Parse JSON body
// 	var callback models.StkCallback
// 	if err := json.Unmarshal(c.Body(), &callback); err != nil {
// 		return c.Status(http.StatusBadRequest).JSON(fiber.Map{"error": "Invalid JSON format"})
// 	}

// 	log.Println("Received Callback:", callback)

// 	// Extract key values
// 	resultCode := callback.Body.StkCallback.ResultCode
// 	resultDesc := callback.Body.StkCallback.ResultDesc
// 	callbackMetadata := callback.Body.StkCallback.CallbackMetadata.Item

// 	// If CallbackMetadata is empty, log and return a failure status
// 	if len(callbackMetadata) == 0 {
// 		fmt.Println("Transaction Failed or Canceled:", resultDesc)
// 		return c.JSON(fiber.Map{
// 			"message": "Transaction Failed or Canceled",
// 			"status":  "failed",
// 		})
// 	}

// 	var mpesaReceiptNumber string
// 	var phoneNumber int64
// 	var amount float64

// 	// Extract values from CallbackMetadata
// 	for _, item := range callbackMetadata {
// 		switch item.Name {
// 		case "MpesaReceiptNumber":
// 			mpesaReceiptNumber = item.Value.(string)
// 		case "PhoneNumber":
// 			phoneNumber = int64(item.Value.(float64))
// 		case "Amount":
// 			amount = item.Value.(float64)
// 		}
// 	}

// 	// Log transaction details
// 	fmt.Printf("Payment received: %+v\n", callback)

// 	// Check if transaction was successful
// 	if resultCode == 0 && mpesaReceiptNumber != "" {
// 		fmt.Println("Transaction Successful:", mpesaReceiptNumber, phoneNumber, amount)
// 		// Save transaction as successful in database
// 	} else {
// 		fmt.Println("Transaction Failed:", resultDesc)
// 	}

// 	// Respond to Safaricom
// 	return c.JSON(fiber.Map{
// 		"message": "Callback received successfully",
// 		"status":  "ok",
// 	})
// }


// func CallbackHandler(c *fiber.Ctx) error {
//     var callbackData models.StkCallback

//     // Parse the incoming JSON request
//     if err := c.BodyParser(&callbackData); err != nil {
//         return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "Invalid callback data"})
//     }

//     log.Println("Full Callback Response:", callbackData)

//     // Check if the response contains the expected structure
//     if body, ok := callbackData["Body"].(map[string]interface{}); ok {
//         if stkCallback, ok := body["stkCallback"].(map[string]interface{}); ok {
//             checkoutID, _ := stkCallback["CheckoutRequestID"].(string)

//             // Extract ResultCode
//             resultCode, ok := stkCallback["ResultCode"].(float64)
//             if !ok {
//                 return c.Status(406).JSON(fiber.Map{"error": "Missing ResultCode"})
//             }

//             var transactionID string

//             // If payment was successful, extract Transaction ID from CallbackMetadata
//             if resultCode == 0 {
//                 if callbackMetadata, ok := stkCallback["CallbackMetadata"].(map[string]interface{}); ok {
//                     if items, ok := callbackMetadata["Item"].([]interface{}); ok {
//                         for _, item := range items {
//                             itemMap, _ := item.(map[string]interface{})
//                             if name, _ := itemMap["Name"].(string); name == "MpesaReceiptNumber" {
//                                 transactionID, _ = itemMap["Value"].(string)
//                             }
//                         }
//                     }
//                 }

                // if transactionID == "" {
                //     log.Println("Missing 'MpesaReceiptNumber' field in callback")
                //     return c.Status(406).JSON(fiber.Map{"error": "Missing MpesaReceiptNumber"})
                // }

                // // Update database with transaction ID
                // var payment models.Payment
                // db.Db.Where("checkout_id = ?", checkoutID).First(&payment)
                // payment.TransactionID = transactionID
                // payment.Status = "Completed"
//                 db.Db.Save(&payment)

//                 return c.SendStatus(fiber.StatusOK)
//             } else {
//                 // Update status as "Failed"
//                 var payment models.Payment
//                 db.Db.Where("checkout_id = ?", checkoutID).First(&payment)
//                 payment.Status = "Failed"
//                 db.Db.Save(&payment)

//                 return c.SendStatus(fiber.StatusOK)
//             }
//         }
//     }

//     // Handle unexpected responses with no "Body"
//     log.Println("Missing 'Body' field in callback")
//     return c.Status(406).JSON(fiber.Map{"error": "Invalid callback structure"})
// }


func CallbackHandler(c *fiber.Ctx) error {
    var callbackData models.StkCallback
	if err := c.BodyParser(&callbackData); err != nil {
        log.Printf("Error parsing callback body: %v", err)
        return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"message": "Invalid callback data", "state": "failed"})
    }


fmt.Println("M-Pesa Callback:", string(c.Body()))
checkoutID:=callbackData.Body.StkCallback.CheckoutRequestID
transactionID:=callbackData.Body.StkCallback.MerchantRequestID


var payment models.Payment

db.Db.Where("checkout_id = ?", checkoutID).First(&payment)

if callbackData.Body.StkCallback.ResultCode == 0 {
		fmt.Println("Transaction successful")
	
		 payment.TransactionID = transactionID
		 payment.Status = "Completed"
		 db.Db.Save(&payment)
		//  return c.Status(200).JSON(fiber.Map{"message":"Transaction successful","state":"success"});

} else {
		fmt.Println("Transaction failed. ResultCode:", callbackData.Body.StkCallback.ResultCode)
		fmt.Println("ResultDesc:", callbackData.Body.StkCallback.ResultDesc)
		
		payment.Status = "Failed"
		db.Db.Save(&payment)
		// return c.Status(400).JSON(fiber.Map{"message":callbackData.Body.StkCallback.ResultDesc,"state":"failed"});

}
 return c.Status(fiber.StatusOK).JSON(fiber.Map{"status":"ok"})
}



func Ping(c *fiber.Ctx)error{
var  ping models.PingModel

if err:=c.BodyParser(&ping);err!=nil{
	return c.Status(400).JSON("bad request")
}
return c.Status(200).JSON("pong")



}
package main

import (
	"log"
	"mpesa/db"
	"mpesa/handles"
	"mpesa/models"

	"github.com/gofiber/fiber/v2"
	"github.com/gofiber/fiber/v2/middleware/cors"
	"github.com/gofiber/fiber/v2/middleware/logger"
)

func init() {
	db.ConnectDb()
}

func main() {
	app := fiber.New()

	
	app.Use(cors.New(cors.Config{
		AllowOrigins: "*",
		AllowMethods: "GET,POST,PUT,DELETE",
		AllowHeaders: "Origin, Content-Type, Accept",
	}))

	app.Use(logger.New())

	app.Post("/stkpush", handles.StkPushHandler)
	app.Post("/callback", handles.CallbackHandler)
	app.Post("/", handles.Ping)
	
	app.Post("/send-email", func(c *fiber.Ctx) error {
		req := new(models.EmailRequest)
		if err := c.BodyParser(req); err != nil {
			return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
				"error": "Invalid request",
			})
		}

		err := handles.SendEmail(req.To, req.Subject, req.Body)
		if err != nil {
			log.Println("Email error:", err)
			return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
				"message": "Failed to send email",
			})
		}

		return c.JSON(fiber.Map{
			"message": "Email sent successfully",
		})
	})



	log.Fatal(app.Listen(":8080"))
}

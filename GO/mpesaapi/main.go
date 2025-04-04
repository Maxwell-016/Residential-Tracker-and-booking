package main

import (
	"log"
	"mpesa/db"
	"mpesa/handles"

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
	


	log.Fatal(app.Listen(":8080"))
}

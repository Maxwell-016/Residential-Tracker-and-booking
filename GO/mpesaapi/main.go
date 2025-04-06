package main

// import (
// 	"fmt"
// 	"mpesa/handles"
// )

import (
	"log"
	"mpesa/db"
	"mpesa/handles"

	"github.com/gofiber/fiber/v2/middleware/logger"

	"github.com/gofiber/fiber/v2"
)

func init(){
	db.ConnectDb()
}

func main() {

	app := fiber.New()
	app.Use(logger.New())

	app.Post("/stkpush", handles.StkPushHandler)
	app.Post("/callback", handles.CallbackHandler)

	log.Fatal(app.Listen(":8080"))
}

// func main() {
//     token, err := handles.GetAccessToken()
//     if err != nil {
//         fmt.Println("Error:", err)
//     } else {
//         fmt.Println("Access Token:", token)
//     }
// }
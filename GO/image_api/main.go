package main

import (
	"log"
	"residential_tracker_images/apiKey"
	"residential_tracker_images/database"
	"residential_tracker_images/handlers"

	"github.com/gofiber/fiber/v2"
)

func init(){
	database.ConnectDb()
	handlers.DirectoryCheck()
}

func main(){

	app:=fiber.New()

	app.Post("/upload",handlers.UploadFile)
	app.Get("/:filename",handlers.DownloadFIle)
	app.Get("/",handlers.ListFiles)

	api:=app.Group("/de",apikey.APIKeyMiddleware(handlers.GetGet))
	api.Delete("lete/:filename",handlers.DeleteFile)

	log.Fatal(app.Listen(":8080"))


}
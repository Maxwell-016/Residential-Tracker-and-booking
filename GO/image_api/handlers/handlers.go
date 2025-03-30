package handlers

import (
	"fmt"
	"os"
	"path/filepath"

	"residential_tracker_images/database"
	"residential_tracker_images/models"

	"github.com/gofiber/fiber/v2"
)

const UploadFolder="./house_images"

func DirectoryCheck(){
	if _,err:=os.Stat(UploadFolder);os.IsNotExist(err){
		if err := os.Mkdir(UploadFolder, os.ModePerm); err != nil {
			fmt.Println("Error creating directory:", err)
		}
		
	}
}

func UploadFile(c *fiber.Ctx)error{
	file,err:=c.FormFile("file")

	if err!=nil{
		return c.Status(400).JSON(fiber.Map{"error":"File upload failed"})
	}

	filePath := filepath.Join(UploadFolder, file.Filename)


	err=c.SaveFile(file,filePath)
	if err!=nil{
		return c.Status(500).JSON(fiber.Map{"error":"Filed to save the file"})

	}

	var image models.ImageModel
	image.ImageName=file.Filename
	image.FilePath=filePath

	database.Db.Create(&image)

	return c.Status(200).JSON(fiber.Map{"message": "File uploaded successfully", "file_path": fmt.Sprintf("https://residential-tracker-and-booking-images.onrender.com/%s", file.Filename)})
}




func DownloadFIle(c *fiber.Ctx)error{
	filename:=c.Params("filename")

	filePath := filepath.Join(UploadFolder, filename)


	// var image models.ImageModel

	// // if err:=database.Db.Where("ImageName = ?",filename).First(&image).Error;err!=nil{
	// // 	return c.Status(404).JSON(fiber.Map{"error":"Image not found"})
	 // }

	if _, err := os.Stat(filePath); os.IsNotExist(err) {
		return c.Status(404).JSON(fiber.Map{"error": "File not found"})
	}
	return c.SendFile(filePath)

}


func ListFiles(c *fiber.Ctx) error {
	var images []models.ImageModel

	if err:=database.Db.Find(&images).Error;err != nil {
		return c.Status(500).JSON(fiber.Map{"error": "Failed to list files"})
	}
	return c.JSON(images)
}

var GetGet="plmnbvcxzaqwertyuio"

func DeleteFile(c *fiber.Ctx) error {

	filename := c.Params("filename")
	filePath := filepath.Join(UploadFolder, filename)

	
	if _, err := os.Stat(filePath); os.IsNotExist(err) {
		return c.Status(404).JSON(fiber.Map{"error": "File not found"})
	}

	
	err := os.Remove(filePath)
	if err != nil {
		return c.Status(500).JSON(fiber.Map{"error": "Failed to delete file from storage"})
	}

	var image models.ImageModel
	result := database.Db.Where("image_name = ?", filename).Delete(&image)
	if result.Error != nil || result.RowsAffected == 0 {
		return c.Status(500).JSON(fiber.Map{"error": "Failed to delete file from database"})
	}

	return c.JSON(fiber.Map{"message": "File deleted successfully"})
}

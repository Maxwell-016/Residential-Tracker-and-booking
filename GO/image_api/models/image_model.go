package models

import(
	"gorm.io/gorm"
)

type ImageModel struct{
	gorm.Model
	ImageName string `json:"image_name"`
	FilePath string `gorm:"unique"`
	//Id uint `json:"id" gorm:"unique" `
}


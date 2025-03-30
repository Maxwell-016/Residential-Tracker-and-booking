package database

import (
	"log"
	"residential_tracker_images/models"

	"gorm.io/driver/postgres"
	"gorm.io/gorm"
)

var Db *gorm.DB

func ConnectDb(){
	var err error
	dsn:="postgresql://neondb_owner:npg_3yAVSZ7CLefq@ep-long-bonus-a8t1sjn8-pooler.eastus2.azure.neon.tech/neondb?sslmode=require"

	Db,err =gorm.Open(postgres.Open(dsn),&gorm.Config{})

	if(err!=nil){
		log.Fatal("error: Failed to connect to database ",err)
	}

	Db.AutoMigrate(&models.ImageModel{})





}


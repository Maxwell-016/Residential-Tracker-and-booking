package db

import (
	"fmt"
	"log"
	"mpesa/models"
	

	"github.com/joho/godotenv"
	"gorm.io/driver/postgres"
	"gorm.io/gorm"
)


var Db *gorm.DB

func ConnectDb(){
	
	err:=godotenv.Load()
	if err!=nil{
		log.Fatal("Error loading env")
	}
	// dsn:=os.Getenv("DB_URL")
	// if dsn==""{
	// 	log.Fatal("Emty Db url")
	// }

	dsn:="postgresql://neondb_owner:npg_3yAVSZ7CLefq@ep-long-bonus-a8t1sjn8-pooler.eastus2.azure.neon.tech/neondb?sslmode=require"

	Db,err=gorm.Open(postgres.Open(dsn),&gorm.Config{})
	if err!=nil{
		log.Fatal("Problem COnnecting to db")
	}

	fmt.Println("succefully connected to db")

	Db.AutoMigrate(&models.Payment{})
	fmt.Println("Table intialized")




}
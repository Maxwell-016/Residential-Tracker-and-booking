package models

import "gorm.io/gorm"


type Payment struct {
	gorm.Model
	PhoneNumber   string
	Amount        int
	CheckoutID    string
	TransactionID string
	Status        string
}
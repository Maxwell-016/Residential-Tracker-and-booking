package handles

import (

	"net/smtp"

	
)

const (
	smtpHost     = "smtp.gmail.com"
	smtpPort     = "587"
	senderEmail  = "nickeagle888@gmail.com"
	senderPass   = "aoqr pvsd ynkk phwi" 
)

func SendEmail(to, subject, body string) error {
	auth := smtp.PlainAuth("", senderEmail, senderPass, smtpHost)

	msg := []byte("To: " + to + "\r\n" +
		"Subject: " + subject + "\r\n" +
		"Content-Type: text/html; charset=\"UTF-8\"\r\n\r\n" +
		body + "\r\n")

	return smtp.SendMail(smtpHost+":"+smtpPort, auth, senderEmail, []string{to}, msg)
}
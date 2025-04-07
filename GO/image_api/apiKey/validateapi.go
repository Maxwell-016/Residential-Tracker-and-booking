package apikey


import "github.com/gofiber/fiber/v2"

func APIKeyMiddleware(apiKey string)fiber.Handler{
	return func(c *fiber.Ctx)error{
		clientKey:=c.Get("X-API-Key")
		if clientKey!=apiKey{
			return c.Status(401).JSON(fiber.Map{"error": "Invalid API Key"})
		}
		return c.Next()
	}
}
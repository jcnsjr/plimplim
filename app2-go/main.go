package main

import (
	"fmt"
	"log"
	"net/http"
	"os"
	"time"

	"github.com/go-redis/redis/v8"
	"github.com/gin-gonic/gin"
	"golang.org/x/net/context"
)

var rdb *redis.Client
var ctx = context.Background()
var redisAvailable bool = true // Flag para saber se o Redis está acessível

// Prefixo a ser adicionado às chaves do Redis
const cachePrefix = "app2-go:"

func initRedis() {
	// Conectar ao Redis
	redisHost := os.Getenv("CACHE_REDIS_HOST")
	if redisHost == "" {
		redisHost = "redis" // Default se não encontrar
	}
	rdb = redis.NewClient(&redis.Options{
		Addr: fmt.Sprintf("%s:6379", redisHost),
	})

	_, err := rdb.Ping(ctx).Result()
	if err != nil {
		log.Printf("⚠️ Redis não disponível: %v. A aplicação rodará sem cache.", err)
		redisAvailable = false // Desativa o uso do Redis
	} else {
		fmt.Println("✅ Conectado ao Redis!")
	}
}

func main() {
	// Tenta iniciar a conexão com Redis
	initRedis()

	// Cria o roteador do Gin
	router := gin.Default()

	// Rota Fixed com cache de 1 minuto
	router.GET("/fixed", func(c *gin.Context) {
		// Adiciona o prefixo à chave
		cacheKey := cachePrefix + "fixed"
		fixedMessage := "Esta é uma resposta fixa."

		// Se o Redis estiver disponível, tenta buscar do cache
		if redisAvailable {
			cachedFixed, err := rdb.Get(ctx, cacheKey).Result()
			if err == redis.Nil {
				// Se não existir no cache, salva no Redis
				err = rdb.Set(ctx, cacheKey, fixedMessage, 1*time.Minute).Err()
				if err != nil {
					log.Printf("Erro ao salvar no cache: %v", err)
				}
			} else if err != nil {
				log.Printf("Erro ao acessar o cache: %v", err)
			} else {
				// Se já estiver no cache, retorna o valor
				fixedMessage = cachedFixed
			}
		}

		c.JSON(http.StatusOK, gin.H{
			"message": fixedMessage,
		})
	})

	// Rota Time com cache de 1 minuto
	router.GET("/time", func(c *gin.Context) {
		// Adiciona o prefixo à chave
		cacheKey := cachePrefix + "time"
		currentTime := time.Now().Format("2006-01-02 15:04:05")

		// Se o Redis estiver disponível, tenta buscar do cache
		if redisAvailable {
			cachedTime, err := rdb.Get(ctx, cacheKey).Result()
			if err == redis.Nil {
				// Se não existir no cache, salva no Redis
				err = rdb.Set(ctx, cacheKey, currentTime, 1*time.Minute).Err()
				if err != nil {
					log.Printf("Erro ao salvar no cache: %v", err)
				}
			} else if err != nil {
				log.Printf("Erro ao acessar o cache: %v", err)
			} else {
				// Se já estiver no cache, retorna o valor
				currentTime = cachedTime
			}
		}

		c.JSON(http.StatusOK, gin.H{
			"server_time": currentTime,
		})
	})

	// Inicia o servidor
	router.Run(":5000")
}

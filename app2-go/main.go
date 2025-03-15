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
		log.Fatalf("Erro ao conectar ao Redis: %v", err)
	}
	fmt.Println("Conectado ao Redis!")
}

func main() {
	// Inicia a conexão com Redis
	initRedis()

	// Cria o roteador do Gin
	router := gin.Default()

	// Rota Fixed com cache de 1 minuto
	router.GET("/fixed", func(c *gin.Context) {
		// Adiciona o prefixo à chave
		cacheKey := cachePrefix + "fixed"

		// Verificar se a chave "fixed" está no cache
		cachedFixed, err := rdb.Get(ctx, cacheKey).Result()
		if err == redis.Nil {
			// Se não existir no cache, retorna a resposta fixa e salva no cache
			fixedMessage := "Esta é uma resposta fixa."
			err = rdb.Set(ctx, cacheKey, fixedMessage, 1*time.Minute).Err()
			if err != nil {
				log.Printf("Erro ao salvar no cache: %v", err)
			}
			c.JSON(http.StatusOK, gin.H{
				"message": fixedMessage,
			})
		} else if err != nil {
			log.Printf("Erro ao acessar o cache: %v", err)
			c.JSON(http.StatusInternalServerError, gin.H{
				"error": "Erro ao acessar o cache",
			})
		} else {
			// Se já estiver no cache, retorna o valor
			c.JSON(http.StatusOK, gin.H{
				"message": cachedFixed,
			})
		}
	})

	// Rota Time com cache de 1 minuto
	router.GET("/time", func(c *gin.Context) {
		// Adiciona o prefixo à chave
		cacheKey := cachePrefix + "time"

		// Verificar se a chave "time" está no cache
		cachedTime, err := rdb.Get(ctx, cacheKey).Result()
		if err == redis.Nil {
			// Se não existir no cache, gera o horário atual e armazena no cache
			currentTime := time.Now().Format("2006-01-02 15:04:05")
			err = rdb.Set(ctx, cacheKey, currentTime, 1*time.Minute).Err()
			if err != nil {
				log.Printf("Erro ao salvar no cache: %v", err)
			}
			c.JSON(http.StatusOK, gin.H{
				"server_time": currentTime,
			})
		} else if err != nil {
			log.Printf("Erro ao acessar o cache: %v", err)
			c.JSON(http.StatusInternalServerError, gin.H{
				"error": "Erro ao acessar o cache",
			})
		} else {
			// Se já estiver no cache, retorna o valor
			c.JSON(http.StatusOK, gin.H{
				"server_time": cachedTime,
			})
		}
	})

	// Inicia o servidor
	router.Run(":5000")
}

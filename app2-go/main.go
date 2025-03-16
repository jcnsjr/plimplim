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

// Função para conectar ao Redis com tentativas repetidas
func connectToRedis() {
	redisHost := os.Getenv("CACHE_REDIS_HOST")
	if redisHost == "" {
		redisHost = "redis"
	}

	rdb = redis.NewClient(&redis.Options{
		Addr: fmt.Sprintf("%s:6379", redisHost),
	})

	// Loop para garantir que o Redis esteja disponível antes de iniciar a aplicação
	for {
		_, err := rdb.Ping(ctx).Result()
		if err == nil {
			fmt.Println("Conectado ao Redis!")
			break
		}

		fmt.Printf("Falha em conectar ao Redis em %s. Tentando novamente em 5 segundos...\n", redisHost)
		time.Sleep(5 * time.Second)
	}
}

func main() {
	// Garante que a conexão com Redis seja estabelecida antes de continuar
	connectToRedis()

	// Cria o roteador do Gin
	router := gin.Default()

	// Rota Fixed com cache de 1 minuto
	router.GET("/fixed", func(c *gin.Context) {
		cacheKey := cachePrefix + "fixed"
		fixedMessage := "Esta é uma resposta fixa da aplicação GO"

		// Tenta buscar do cache
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

		c.JSON(http.StatusOK, gin.H{
			"message": fixedMessage,
		})
	})

	// Rota Time com cache de 1 minuto
	router.GET("/time", func(c *gin.Context) {
		cacheKey := cachePrefix + "time"
		currentTime := time.Now().Format("2006-01-02 15:04:05")

		// Tenta buscar do cache
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

		c.JSON(http.StatusOK, gin.H{
			"server_time": currentTime,
		})
	})

	// Inicia o servidor
	router.Run(":5000")
}

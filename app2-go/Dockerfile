# Etapa 1: Construção da aplicação
# Usa uma imagem oficial do Go como base para compilar a aplicação
FROM golang:1.18-alpine AS builder

# Define o diretório de trabalho dentro do container
WORKDIR /app

# Copia os arquivos go.mod e go.sum
COPY go.mod go.sum ./

# Baixa as dependências
RUN go mod tidy

# Copia o código da aplicação para dentro do container
COPY . .

# Compila o código Go para um binário
RUN GOOS=linux GOARCH=amd64 go build -o app main.go


# Etapa 2: Imagem final
# Usa uma imagem minimalista (sem Go) para rodar a aplicação
FROM alpine:latest

# Define o diretório de trabalho
WORKDIR /root/

# Copia o binário compilado da etapa anterior
COPY --from=builder /app/app .

# Expõe a porta onde a aplicação irá rodar
EXPOSE 5000

# Comando para rodar a aplicação
CMD ["./app"]

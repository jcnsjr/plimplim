# Usa uma imagem oficial do Go como base
FROM golang:1.18-alpine

# Define o diretório de trabalho dentro do container
WORKDIR /app

# Copia os arquivos go.mod e go.sum
COPY go.mod go.sum ./

# Baixa as dependências
RUN go mod tidy

# Copia o código da aplicação para dentro do container
COPY . .

# Expõe a porta onde a aplicação irá rodar
EXPOSE 5000

# Comando para rodar a aplicação
CMD ["go", "run", "main.go"]
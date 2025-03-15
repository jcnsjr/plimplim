# Usa uma imagem leve do Python
FROM python:3.11-alpine

# Define o diretório de trabalho dentro do container
WORKDIR /app

# Copia apenas os arquivos necessários
COPY requirements.txt .

# Instala as dependências sem cache para reduzir a imagem
RUN pip install --no-cache-dir -r requirements.txt

# Copia o restante do código para dentro do container
COPY . .

# Expõe a porta usada pelo Flask
EXPOSE 5000

# Comando para rodar a aplicação
CMD ["python", "app.py"]

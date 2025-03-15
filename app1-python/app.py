import os
from flask import Flask, jsonify
from flask_caching import Cache
from datetime import datetime
import redis

app = Flask(__name__)

# Obtém o host do Redis da variável de ambiente
REDIS_HOST = os.getenv("CACHE_REDIS_HOST", "localhost")

# Testa conexão com Redis
try:
    redis_client = redis.Redis(host=REDIS_HOST, port=6379, decode_responses=True)
    redis_client.ping()
    print(f"Conectado ao {REDIS_HOST}")
except redis.ConnectionError:
    print(f"Erro: Não foi possível conectar ao {REDIS_HOST}")

# Configuração do cache no Redis
app.config["CACHE_TYPE"] = "RedisCache"
app.config["CACHE_REDIS_HOST"] = REDIS_HOST
app.config["CACHE_REDIS_PORT"] = 6379
app.config["CACHE_DEFAULT_TIMEOUT"] = 10
app.config["CACHE_KEY_PREFIX"] = "app1-python:"  # Prefixo para diferenciar


cache = Cache(app)

@app.route("/fixed")
@cache.cached()
def fixed_text():
    return jsonify({"fixed_text": "Retornando um texto fixo."})

@app.route("/time")
@cache.cached()
def server_time():
    return jsonify({"server_time": datetime.now().strftime("%Y-%m-%d %H:%M:%S")})

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)

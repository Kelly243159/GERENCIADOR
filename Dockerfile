FROM python:3.12-slim

# Evita prompts interativos
ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1

WORKDIR /app

# Instala dependências
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copia código da aplicação
COPY main.py .

# Cloud Run usa a variável PORT (padrão 8080)
ENV PORT=8080

EXPOSE 8080

# Executa a aplicação
CMD ["python", "main.py"]

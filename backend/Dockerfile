FROM python:3.12-slim

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements first for Docker layer caching
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY . .

# Railway injects PORT env variable
CMD python -c "import os, uvicorn; uvicorn.run('app.main:app', host='0.0.0.0', port=int(os.environ.get('PORT', 8000)))"

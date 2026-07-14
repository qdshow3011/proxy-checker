FROM python:3.12-slim

WORKDIR /app

# Install system dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends curl && \
    rm -rf /var/lib/apt/lists/*

# Install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application files
COPY server.py proxy_check.py fetch_proxies.py ./
COPY config.json ./
COPY index.html login.html app.js ./
COPY api/ ./api/
COPY tools/ ./tools/

# Create runtime directories
RUN mkdir -p repo_data checked_data auto_data run_logs

EXPOSE 8888

# Health check
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD curl -f http://localhost:8888/api/capabilities -X POST -H "Content-Type: application/json" -d '{}' || exit 1

CMD ["python", "-u", "server.py"]

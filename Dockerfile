# Multi-stage build for optimized Docker image
# Stage 1: Builder
FROM python:3.11-slim AS builder

# Set working directory
WORKDIR /app

# Install system dependencies for building
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements first for better layer caching
COPY requirements.txt .

# Install Python dependencies
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir --target=/app/dependencies -r requirements.txt

# Stage 2: Runtime
FROM python:3.11-slim

# Set environment variables
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONPATH=/app/dependencies \
    PORT=8040

# Install runtime dependencies for Pyppeteer/Chromium
RUN apt-get update && apt-get install -y --no-install-recommends \
    # Chromium dependencies
    libnss3 \
    libnspr4 \
    libatk1.0-0 \
    libatk-bridge2.0-0 \
    libcups2 \
    libdrm2 \
    libdbus-1-3 \
    libxkbcommon0 \
    libatspi2.0-0 \
    libxcomposite1 \
    libxdamage1 \
    libxfixes3 \
    libxrandr2 \
    libgbm1 \
    libasound2 \
    libpango-1.0-0 \
    libcairo2 \
    libxshmfence1 \
    fonts-liberation \
    libappindicator3-1 \
    libgtk-3-0 \
    libx11-xcb1 \
    # Utilities
    ca-certificates \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Create app directory
WORKDIR /app

# Copy Chinese font for proper rendering
RUN mkdir -p /usr/share/fonts/chinese/
COPY weiruanyahei.ttf /usr/share/fonts/chinese/
RUN fc-cache -fv || true

# Copy Python dependencies from builder
COPY --from=builder /app/dependencies /app/dependencies

# Copy application code
COPY util/ /app/util/
COPY *.py /app/

# Create logs directory and set permissions
RUN mkdir -p /app/logs && \
    chmod +x /app/main*.py && \
    useradd -m -u 1000 appuser && \
    chown -R appuser:appuser /app

# Switch to non-root user for security
USER appuser

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD python -c "import requests; requests.get('http://localhost:${PORT}/health', timeout=5)" || exit 1

# Expose port
EXPOSE ${PORT}

# Start application
CMD ["sh", "-c", "uvicorn main_api:app --host 0.0.0.0 --port ${PORT} --workers 2 --log-level info"]

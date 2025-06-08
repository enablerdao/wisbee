# 🐝 Wisbee Docker Image
FROM node:20-slim

# Install Python and required system dependencies
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    curl \
    git \
    && rm -rf /var/lib/apt/lists/*

# Create app directory
WORKDIR /app

# Copy package files
COPY wisbee-mac/package*.json ./wisbee-mac/
COPY requirements.txt ./

# Install Node.js dependencies
WORKDIR /app/wisbee-mac
RUN npm ci --only=production

# Install Python dependencies
WORKDIR /app
RUN pip3 install -r requirements.txt || true

# Copy application files
COPY wisbee-mac ./wisbee-mac
COPY ollama-webui-server.py .
COPY config.json .
COPY index.html .

# Expose ports
EXPOSE 8899

# Start the application
WORKDIR /app/wisbee-mac
CMD ["npm", "start"]
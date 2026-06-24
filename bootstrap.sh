#!/bin/bash
set -e

echo "Starting host initialization..."

# Update and install basic dependencies
sudo apt-get update
sudo apt-get install -y curl vim git ca-certificates gnupg certbot

# Install Docker if not present
if ! command -v docker &> /dev/null; then
    echo "Installing Docker..."
    sudo install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    sudo chmod a+r /etc/apt/keyrings/docker.gpg

    echo \
      "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
      "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
      sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
fi

# Ensure current user can run docker
if ! groups $USER | grep &>/dev/null "\bdocker\b"; then
    echo "Adding $USER to docker group..."
    sudo usermod -aG docker $USER
    echo "Please log out and back in for group changes to take effect."
fi

# Create config directory if not exists
mkdir -p config

# Check default .bashrc file and append sourcing of jarvis.bashrc if not present
BASHRC_FILE="$HOME/.bashrc"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
JARVIS_BASHRC="$SCRIPT_DIR/jarvis.bashrc"

echo "Checking if $JARVIS_BASHRC is sourced in $BASHRC_FILE..."
if [ -f "$BASHRC_FILE" ]; then
    if ! grep -qF "$JARVIS_BASHRC" "$BASHRC_FILE"; then
        echo "Adding sourcing line to $BASHRC_FILE"
        echo "" >> "$BASHRC_FILE"
        echo "# Source Jarvis environment configuration" >> "$BASHRC_FILE"
        echo "source \"$JARVIS_BASHRC\"" >> "$BASHRC_FILE"
    fi
else
    echo "Creating $BASHRC_FILE and adding sourcing line"
    echo "source \"$JARVIS_BASHRC\"" > "$BASHRC_FILE"
fi

if [ -f "$JARVIS_BASHRC" ]; then
    source "$JARVIS_BASHRC"
fi

# Let's Encrypt Certificate Check & Generation
ENV_FILE="$SCRIPT_DIR/.env"
if [ -f "$ENV_FILE" ]; then
    DOMAIN_NAME=$(grep -v '^#' "$ENV_FILE" | grep "^DOMAIN_NAME=" | cut -d'=' -f2- | tr -d '"' | tr -d "'" | tr -d ' ')
    CERT_DOMAIN=$(grep -v '^#' "$ENV_FILE" | grep "^CERT_DOMAIN=" | cut -d'=' -f2- | tr -d '"' | tr -d "'" | tr -d ' ')
    EMAIL=$(grep -v '^#' "$ENV_FILE" | grep "^LETSENCRYPT_EMAIL=" | cut -d'=' -f2- | tr -d '"' | tr -d "'" | tr -d ' ')

    if [ -n "$DOMAIN_NAME" ]; then
        if [ -z "$CERT_DOMAIN" ]; then
            CERT_DOMAIN="$DOMAIN_NAME"
        fi

        CERT_PATH="/etc/letsencrypt/live/${CERT_DOMAIN}/fullchain.pem"
        if [ ! -f "$CERT_PATH" ]; then
            echo "SSL Certificate for ${CERT_DOMAIN} not found. Attempting to generate one..."

            # Stop Nginx if it's currently running via docker compose
            if command -v docker &> /dev/null; then
                echo "Stopping Nginx to free up port 80..."
                docker compose -f "$SCRIPT_DIR/docker-compose.yml" stop nginx || true
            fi

            # Prepare domain arguments
            DOMAIN_ARGS="-d ${CERT_DOMAIN}"
            if [ "${DOMAIN_NAME}" != "${CERT_DOMAIN}" ]; then
                DOMAIN_ARGS="${DOMAIN_ARGS} -d ${DOMAIN_NAME}"
            fi

            # Prepare email arguments
            if [ -n "$EMAIL" ]; then
                EMAIL_ARGS="-m ${EMAIL}"
            else
                EMAIL_ARGS="--register-unsafely-without-email"
            fi

            # Run certbot standalone
            echo "Running Certbot standalone..."
            sudo certbot certonly --standalone ${DOMAIN_ARGS} --non-interactive --agree-tos ${EMAIL_ARGS}

            # Restart Nginx
            if command -v docker &> /dev/null; then
                echo "Starting Nginx..."
                docker compose -f "$SCRIPT_DIR/docker-compose.yml" up -d --build nginx || true
            fi
        else
            echo "SSL Certificate for ${CERT_DOMAIN} already exists."
        fi
    fi
else
    echo "No .env file detected. Skipping SSL certificate generation."
    echo "Once you create and configure your .env file, you can re-run ./bootstrap.sh to set up SSL."
fi

echo "Host initialization complete."

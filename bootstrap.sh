#!/bin/bash
set -e

echo "Starting host initialization..."

# Update and install basic dependencies
sudo apt-get update
sudo apt-get install -y curl vim git ca-certificates gnupg

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

source .bashrc

echo "Host initialization complete."

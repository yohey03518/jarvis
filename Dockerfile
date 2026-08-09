# Stage 1: Build cc-connect from source code
FROM golang:latest AS cc-connect-builder
ENV GOTOOLCHAIN=auto
WORKDIR /src
RUN git clone https://github.com/chenhg5/cc-connect.git . \
    && mkdir -p web/dist && touch web/dist/.gitkeep \
    && CGO_ENABLED=0 go build -ldflags="-s -w" -o /usr/local/bin/cc-connect ./cmd/cc-connect

# Stage 2: Runtime image
FROM ubuntu:24.04
ENV DEBIAN_FRONTEND=noninteractive

# Copy compiled cc-connect binary from builder
COPY --from=cc-connect-builder /usr/local/bin/cc-connect /usr/local/bin/cc-connect

# Install dependencies
RUN apt-get update && apt-get install -y \
    curl \
    git \
    vim \
    ca-certificates \
    gnupg \
    && curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/*

# Install Docker CLI
RUN install -m 0755 -d /etc/apt/keyrings \
    && curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc \
    && chmod a+r /etc/apt/keyrings/docker.asc \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
       $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null \
    && apt-get update \
    && apt-get install -y docker-ce-cli \
    && rm -rf /var/lib/apt/lists/*

# Install AI CLIs
# 1. Claude Code
#RUN curl -fsSL https://claude.ai/install.sh | bash

# 2. Antigravity CLI
RUN curl -fsSL https://antigravity.google/cli/install.sh | bash

# 3. Codex CLI
#RUN npm install -g @openai/codex

# Ensure binaries are in PATH
ENV PATH="/root/.local/bin:${PATH}"

# 4. Codex CLI & 5. pnpm (cc-connect is built from source above)
RUN npm install -g @openai/codex pnpm

# Copy and set up the entrypoint script
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

WORKDIR /root/agent
EXPOSE 8080

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

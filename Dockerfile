# Stage 1: Build cc-connect
FROM golang:1.22-bookworm AS builder
ARG CC_CONNECT_VERSION=d66540236f0041823c970f08448ca93cfacf95e0
WORKDIR /app
RUN git clone https://github.com/chenhg5/cc-connect.git . && \
    git checkout $CC_CONNECT_VERSION && \
    go mod download && \
    go build -o cc-connect ./cmd/cc-connect

# Stage 2: Final Image
FROM ubuntu:24.04
ENV DEBIAN_FRONTEND=noninteractive

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

# Install AI CLIs
# 1. Claude Code
RUN curl -fsSL https://claude.ai/install.sh | bash

# 2. Antigravity CLI
RUN curl -fsSL https://antigravity.google/cli/install.sh | bash

# Ensure binaries are in PATH
ENV PATH="/root/.local/bin:${PATH}"

# 3. Codex CLI
RUN npm install -g @openai/codex

# Copy cc-connect binary
COPY --from=builder /app/cc-connect /usr/local/bin/cc-connect

WORKDIR /root/agent
ENTRYPOINT ["cc-connect"]

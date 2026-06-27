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
#RUN curl -fsSL https://claude.ai/install.sh | bash

# 2. Antigravity CLI
RUN curl -fsSL https://antigravity.google/cli/install.sh | bash

# 3. Codex CLI
#RUN npm install -g @openai/codex

# Ensure binaries are in PATH
ENV PATH="/root/.local/bin:${PATH}"

# 4. CC Connect & 5. pnpm
RUN npm install -g cc-connect pnpm

# Copy and set up the entrypoint script
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

WORKDIR /root/agent
EXPOSE 8080

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

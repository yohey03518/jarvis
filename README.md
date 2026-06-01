# Personal AI Agent Server

This repository contains the configuration and scripts to set up a personal AI agent bridge between LINE and various AI CLIs (Claude Code, Antigravity CLI, and Codex).

## Features
- **cc-connect**: A bridge for local AI agents.
- **AI CLIs**: Pre-installed Claude Code, Antigravity CLI, and Codex.
- **Portability**: Managed via Docker and a host bootstrap script.

## Setup
1. **Initial Clone**:
   ```bash
   git clone <your-repo-url>
   cd jarvis
   ```
2. **Host Initialization**:
   ```bash
   ./bootstrap.sh
   ```
3. **Environment Setup**:
   ```bash
   cp .env.example .env
   # Edit .env with your API keys
   ```
4. **Configuration**:
   ```bash
   cp config/config.example.toml config/config.toml
   # Edit config/config.toml if needed
   ```
5. **Start Agent**:
   ```bash
   docker compose up -d --build
   ```

## Maintenance
Whenever you update the repository or change the configuration:
1. `git pull`
2. `./bootstrap.sh`
3. `docker compose up -d --build`

## Secrets Management
- `.env`: Stores sensitive API keys (never commit this).
- `config/config.toml`: Stores `cc-connect` configuration (never commit this).

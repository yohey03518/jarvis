# Personal AI Agent Server

This repository contains the configuration and scripts to set up a personal AI agent bridge between LINE and various AI CLIs (Claude Code, Antigravity CLI, and Codex).

## Features
- **cc-connect**: A bridge for local AI agents.
- **Nginx Reverse Proxy**: A secure frontend reverse proxy handling rate-limiting (5 requests/sec per IP), blocking scanner bots, and dropping raw IP scanning attempts.
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
4. **Start Agent**:
   ```bash
   docker compose up -d --build
   ```
   *Note: Nginx exposes port `80` to the host, while the internal agent service running on port `8080` is kept isolated inside the container network.*

5. **Authenticate Antigravity CLI (agy)**:
   On your first setup, you must authenticate the `agy` CLI inside the container. Run:
   ```bash
   docker compose exec -it agent agy
   ```
   Follow the prompts to complete the Google authentication. Since the host's `./.gemini` path is mounted to `/root/.gemini` inside the container, your credentials will be preserved across container restarts or rebuilds.

## Maintenance
Whenever you update the repository or change the configuration:
1. `git pull`
2. `./bootstrap.sh`
3. `docker compose up -d --build`

## Secrets Management
- `.env`: Stores sensitive API keys and LINE tokens (never commit this).
- `config/config.toml`: Stores `cc-connect` project/agent/platform structure and links credentials to `.env` variables (this is safe to commit).

## Customizing the Callback Path
If you want to customize the callback path (default is `/message`) for your instant messenger (e.g., LINE webhook):
1. **Config TOML**: Update `callback_path` under `[projects.platforms.options]` in `config/config.toml`:
   ```toml
   callback_path = "/new-path"
   ```
2. **Nginx Configuration**: Update the location block and proxy path in `nginx/default.conf` to match:
   ```nginx
   location = /new-path {
       ...
       proxy_pass http://agent:8080/new-path;
   }
   ```
3. **Restart the services** to apply changes:
   ```bash
   docker compose up -d --build
   ```



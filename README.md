# Personal AI Agent Server

This repository contains the configuration and scripts to set up a personal AI agent bridge between LINE/Slack and various AI CLIs (Claude Code, Antigravity CLI, and Codex).

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
2. **Environment Setup**:
   ```bash
   cp .env.example .env
   # Edit .env with your API keys, domain details, and agent workspace configuration.
   ```
3. **Host Initialization & SSL Setup**:
   ```bash
   ./bootstrap.sh
   ```
   *Note: This script installs system dependencies (including Docker and Certbot), clones the workspace repository to your host using the configured SSH key, and automatically checks/generates your Let's Encrypt SSL certificates using the domain details in your `.env`.*
4. **Start Agent**:
   ```bash
   docker compose up -d --build
   ```
   *Note: Nginx exposes ports `80` and `443` to the host, while the internal agent service running on port `8080` is kept isolated inside the container network.*

5. **Authenticate Antigravity CLI (agy)**:
   On your first setup, you must authenticate the `agy` CLI inside the container. Run:
   ```bash
   docker compose exec -it agent agy
   ```
   Follow the prompts to complete the Google authentication. Since the host's `./.gemini` path is mounted to `/root/.gemini` inside the container, your credentials will be preserved across container restarts or rebuilds.

### Workspace Git SSH Setup
If you configure an external workspace git repository, you must set up an SSH key to allow the agent container to push and pull changes:
1. **Generate a passwordless SSH key pair** on the host machine:
   ```bash
   ssh-keygen -t ed25519 -C "jarvis-agent@local" -f ~/.ssh/jarvis_deploy_key
   ```
2. **Add the public key to your Git provider**:
   * Copy the public key contents: `cat ~/.ssh/jarvis_deploy_key.pub`
   * Add it as a **Deploy Key** with **Write Access** enabled in your target repository's settings.
3. **Configure your SSH config file** (`~/.ssh/config`) on the host to map the new key to your Git host (e.g. `github.com`):
   ```text
   Host github.com
       HostName github.com
       User git
       IdentityFile ~/.ssh/jarvis_deploy_key
       IdentitiesOnly yes
   ```
4. **Configure the private key path** in `.env` under `WORKSPACE_SSH_KEY_PATH`.

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



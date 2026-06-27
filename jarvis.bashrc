alias d=docker
alias dc="docker compose"
alias dcr="docker compose restart"
alias dcub="docker compose up -d --build"
alias dcd="docker compose down"
alias dex="docker compose -f \"$HOME/jarvis/docker-compose.yml\" exec agent sh"
alias dlog="docker compose -f \"$HOME/jarvis/docker-compose.yml\" logs agent"

alias cc=clear

alias gpp="git pull"
alias update="cd ~/jarvis-workspace && git pull && cd ~/jarvis && git pull && bash ./bootstrap.sh && dcub"


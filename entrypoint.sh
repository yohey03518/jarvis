#!/bin/bash
set -e

# Set up SSH directory
mkdir -p /root/.ssh
chmod 700 /root/.ssh

# Copy the mounted SSH key to the correct location and fix permissions
if [ -f /tmp/ssh_key ]; then
    cp /tmp/ssh_key /root/.ssh/id_rsa
    chmod 600 /root/.ssh/id_rsa
    
    # Disable strict host key checking to prevent interactive prompts
    echo -e "Host *\n\tStrictHostKeyChecking no\n\tUserKnownHostsFile /dev/null\n" > /root/.ssh/config
    chmod 600 /root/.ssh/config
fi

# Configure Git user identity dynamically from env vars
if [ -n "$GIT_USER_NAME" ]; then
    git config --global user.name "$GIT_USER_NAME"
fi
if [ -n "$GIT_USER_EMAIL" ]; then
    git config --global user.email "$GIT_USER_EMAIL"
fi

# Execute the original entrypoint command
exec cc-connect "$@"

#!/bin/sh
set -e

HTPASSWD_FILE="/etc/nginx/.htpasswd"

if [ -n "$BASIC_AUTH_USER" ] && [ -n "$BASIC_AUTH_PASSWORD" ]; then
    echo "Generating $HTPASSWD_FILE for user '$BASIC_AUTH_USER'..."
    htpasswd -bc "$HTPASSWD_FILE" "$BASIC_AUTH_USER" "$BASIC_AUTH_PASSWORD"
else
    echo "BASIC_AUTH_USER and BASIC_AUTH_PASSWORD not set. Creating empty $HTPASSWD_FILE."
    touch "$HTPASSWD_FILE"
fi

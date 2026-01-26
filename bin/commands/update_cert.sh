#!/bin/bash
set -e

SSL_DIR="./ssl"
CONF_FILE="$SSL_DIR/sites.conf"
KEY_FILE="$SSL_DIR/sites.key"
CRT_FILE="$SSL_DIR/sites.crt"

mkdir -p "$SSL_DIR"

openssl req -config "$CONF_FILE" -x509 -nodes -days 3650 \
    -newkey rsa:2048 -keyout "$KEY_FILE" -out "$CRT_FILE"

echo "Certificate generated at $CRT_FILE"

#!/bin/bash
set -e

CRT_FILE="./ssl/sites.crt"

if [[ "$(uname -s)" == "Darwin" ]]; then
    echo "Trusting certificate on macOS..."
    sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain "$CRT_FILE"
elif [[ "$(uname -s)" == "Linux" ]]; then
    echo "Trusting certificate on Linux..."
    sudo cp "$CRT_FILE" /usr/local/share/ca-certificates/sites.crt
    sudo update-ca-certificates
else
    echo "Unsupported OS"
    exit 1
fi

echo "Certificate trusted!"

#!/bin/bash
set -e

INPUT_FILE="./ssl/sites.conf"
IP_ADDRESS="127.0.0.1"
START_MARKER="# TRAEFIK CUSTOM HOSTS START"
END_MARKER="# TRAEFIK CUSTOM HOSTS END"

if [ ! -f "$INPUT_FILE" ]; then
    echo "Error: '$INPUT_FILE' not found!"
    exit 1
fi

DNS_ENTRIES=$(awk '/\[ alternate_names \]/ {flag=1; next} /^\[/ {flag=0} flag && /^DNS/ {print $NF}' "$INPUT_FILE")

sudo cp /etc/hosts /etc/hosts.bak
TMP_FILE=$(mktemp)

sed -n "1,/$START_MARKER/p" /etc/hosts | grep -v "$START_MARKER" > "$TMP_FILE"

{
    echo "$START_MARKER"
    for DNS in $DNS_ENTRIES; do
        echo "$IP_ADDRESS $DNS"
    done
    echo "$END_MARKER"
} >> "$TMP_FILE"

sed -n "/$END_MARKER/,\$p" /etc/hosts | grep -v "$END_MARKER" >> "$TMP_FILE"

sudo mv "$TMP_FILE" /etc/hosts

# Permissions
if [[ "$(uname -s)" == "Darwin" ]]; then
    sudo chown root:wheel /etc/hosts
else
    sudo chown root:root /etc/hosts
fi
sudo chmod 644 /etc/hosts

echo "Hosts file updated!"

# Flush DNS cache
if [[ "$(uname -s)" == "Darwin" ]]; then
    sudo dscacheutil -flushcache
    sudo killall -HUP mDNSResponder || true
elif command -v systemd-resolve &>/dev/null || command -v resolvectl &>/dev/null; then
    sudo resolvectl flush-caches || true
elif command -v nscd &>/dev/null; then
    sudo nscd -i hosts || true
fi

echo "DNS cache flushed!"

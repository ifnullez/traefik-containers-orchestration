#!/bin/bash
set -e

INPUT_FILE="./ssl/sites.conf"
IP_ADDRESS="127.0.0.1"
START_MARKER="# TRAEFIK CUSTOM HOSTS START"
END_MARKER="# TRAEFIK CUSTOM HOSTS END"

# check if /ssl/sites.conf exists
if [ ! -f "$INPUT_FILE" ]; then
    echo "Error: '$INPUT_FILE' not found!"
    exit 1
fi

# get all hosts names from sites.conf [ alternate_names ] section
DNS_ENTRIES=$(awk '/\[ alternate_names \]/ {flag=1; next} /^\[/ {flag=0} flag && /^DNS/ {print $NF}' "$INPUT_FILE")

# Make backup of original hosts file
sudo cp /etc/hosts /etc/hosts.bak

# removing old Traefik block from /etc/hosts
TMP_FILE=$(mktemp)
awk -v start="$START_MARKER" -v end="$END_MARKER" '
    $0 == start {skip=1}
    $0 == end {skip=0; next}
    skip==0 {print}' /etc/hosts > "$TMP_FILE"

# Adding new traefic block to hosts
{
    echo "$START_MARKER"
    for DNS in $DNS_ENTRIES; do
        echo "$IP_ADDRESS $DNS"
    done
    echo "$END_MARKER"
} >> "$TMP_FILE"

# replace /etc/hosts
sudo mv "$TMP_FILE" /etc/hosts

# restore file rights
if [[ "$(uname -s)" == "Darwin" ]]; then
    sudo chown root:wheel /etc/hosts
else
    sudo chown root:root /etc/hosts
fi
sudo chmod 644 /etc/hosts

echo "Hosts file updated!"

# clear DNS cache
if [[ "$(uname -s)" == "Darwin" ]]; then
    sudo dscacheutil -flushcache
    sudo killall -HUP mDNSResponder || true
elif command -v resolvectl &>/dev/null; then
    sudo resolvectl flush-caches || true
elif command -v systemd-resolve &>/dev/null; then
    sudo systemd-resolve --flush-caches || true
elif command -v nscd &>/dev/null; then
    sudo nscd -i hosts || true
fi

echo "DNS cache flushed!"

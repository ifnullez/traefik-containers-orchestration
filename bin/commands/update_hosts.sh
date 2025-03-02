#!/bin/bash

# Define the input file (relative to the script location)
INPUT_FILE="./ssl/sites.conf"

# Define the IP address for mapping (e.g., localhost)
IP_ADDRESS="127.0.0.1"

# Define markers
START_MARKER="# TRAEFIK CUSTOM HOSTS START"
END_MARKER="# TRAEFIK CUSTOM HOSTS END"

# Check if the input file exists
if [ ! -f "$INPUT_FILE" ]; then
  echo "Error: Input file '$INPUT_FILE' not found."
  exit 1
fi

# Extract DNS entries from the file
DNS_ENTRIES=$(awk '/\[ alternate_names \]/ {flag=1; next} /^\[/ {flag=0} flag && /^DNS/ {print $NF}' "$INPUT_FILE")

# Backup the /etc/hosts file
sudo cp /etc/hosts /etc/hosts.bak

# Create a temporary hosts file
TMP_FILE=$(mktemp)

# Copy everything up to the start marker into the temporary file
sed -n "1,/$START_MARKER/p" /etc/hosts | grep -v "$START_MARKER" > "$TMP_FILE"

# Add the start marker and new DNS entries
{
  echo "$START_MARKER"
  for DNS in $DNS_ENTRIES; do
    echo "$IP_ADDRESS $DNS"
  done
  echo "$END_MARKER"
} >> "$TMP_FILE"

# Copy everything after the end marker into the temporary file
sed -n "/$END_MARKER/,\$p" /etc/hosts | grep -v "$END_MARKER" >> "$TMP_FILE"

# Replace the old hosts file with the updated one
sudo mv "$TMP_FILE" /etc/hosts
sudo chown root:wheel /etc/hosts
sudo chmod 644 /etc/hosts

echo "Hosts file updated successfully!"

# drop system DNS caches
if [[ "$(uname -s)" == "Darwin" ]]; then
    sudo dscacheutil -flushcache
    sudo killall -HUP mDNSResponder
    echo "System DNS caches dropped successfully!"
fi

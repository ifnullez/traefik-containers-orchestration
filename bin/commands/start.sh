#!/usr/bin/env bash
set -euo pipefail

# Ensure the script is executed with bash (not sh)
if [ -z "${BASH_SOURCE[0]+x}" ]; then
    echo "This script must be run with bash, not sh."
    exit 1
fi

# Resolve the script directory (go one level up from ./bin/commands)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "SCRIPT_DIR=$SCRIPT_DIR"

# Load helper scripts
source "$SCRIPT_DIR/container_cmd.sh"
source "$SCRIPT_DIR/compose_cmd.sh"
source "$SCRIPT_DIR/network.sh"

# Detect container engine and compose command
CONTAINER_CMD=$(get_container_cmd)
COMPOSE_CMD=$(get_compose_cmd "$CONTAINER_CMD")

# Exit if neither Podman nor Docker compose is available
if [[ "$CONTAINER_CMD" == "error" || "$COMPOSE_CMD" == "error" ]]; then
    echo "Neither Podman nor Docker compose is available. Exiting..."
    exit 1
fi

# List of possible compose files
POSSIBLE_FILES=("traefik-compose.yml" "docker-compose.yml" "compose.yml")
COMPOSE_FILE=""

# Find the first available compose file
for f in "${POSSIBLE_FILES[@]}"; do
    if [[ -f "$f" ]]; then
        COMPOSE_FILE="$f"
        break
    fi
done

# Exit if no compose file is found
if [[ -z "$COMPOSE_FILE" ]]; then
    echo "Error: No compose file found! Tried: ${POSSIBLE_FILES[*]}"
    exit 1
fi

echo "Using compose file: $COMPOSE_FILE"

# Ensure the network exists (helper script handles creation if missing)
manage_network "$CONTAINER_CMD"

# Start services with build and detach options
$COMPOSE_CMD -f "$COMPOSE_FILE" up --build -d

echo "Traefik started successfully!"

# structure (for reference)
# ./bin
# ├── commands
# │   ├── down.sh
# │   ├── start.sh
# │   ├── stop.sh
# │   ├── trust_cert.sh
# │   ├── update_cert.sh
# │   └── update_hosts.sh
# ├── compose_cmd.sh
# ├── container_cmd.sh
# └── network.sh

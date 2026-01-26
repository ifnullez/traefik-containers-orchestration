#!/usr/bin/env bash
set -euo pipefail

# Ensure the script is executed with bash (not sh)
if [ -z "${BASH_SOURCE[0]+x}" ]; then
    echo "This script must be run with bash, not sh."
    exit 1
fi

# Resolve the script directory (go one level up from ./bin/commands)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Load helper scripts
source "$SCRIPT_DIR/container_cmd.sh"
source "$SCRIPT_DIR/compose_cmd.sh"

# Detect container engine and compose command
CONTAINER_CMD=$(get_container_cmd)
COMPOSE_CMD=$(get_compose_cmd "$CONTAINER_CMD")

# Exit if neither Podman nor Docker compose is available
if [[ "$CONTAINER_CMD" == "error" || "$COMPOSE_CMD" == "error" ]]; then
    echo "Neither Podman nor Docker compose is available. Exiting..."
    exit 1
fi

# Stop running containers (without removing them)
$COMPOSE_CMD stop

echo "Containers stopped successfully!"

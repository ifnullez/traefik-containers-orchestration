#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/.."

source "$SCRIPT_DIR/container_cmd.sh"
source "$SCRIPT_DIR/compose_cmd.sh"
source "$SCRIPT_DIR/network.sh"

CONTAINER_CMD=$(get_container_cmd)
COMPOSE_CMD=$(get_compose_cmd "$CONTAINER_CMD")

if [[ "$CONTAINER_CMD" == "error" || "$COMPOSE_CMD" == "error" ]]; then
    echo "Neither Podman nor Docker compose is available. Exiting..."
    exit 1
fi

# створюємо/перевіряємо мережу
manage_network "$CONTAINER_CMD"

# запускаємо контейнери
$COMPOSE_CMD up --build -d

echo "Containers started successfully!"

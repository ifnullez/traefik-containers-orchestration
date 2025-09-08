#!/bin/bash
set -e

source ./bin/container_cmd.sh
source ./bin/compose_cmd.sh
source ./bin/network.sh

CONTAINER_CMD=$(get_container_cmd)
COMPOSE_CMD=$(get_compose_cmd "$CONTAINER_CMD")

if [[ "$CONTAINER_CMD" == "error" || "$COMPOSE_CMD" == "error" ]]; then
    echo "Neither Podman nor Docker compose is available. Exiting..."
    exit 1
fi

POSSIBLE_FILES=("traefik-compose.yml" "docker-compose.yml" "compose.yml")
COMPOSE_FILE=""

for f in "${POSSIBLE_FILES[@]}"; do
    if [[ -f "$f" ]]; then
        COMPOSE_FILE="$f"
        break
    fi
done

if [[ -z "$COMPOSE_FILE" ]]; then
    echo "Error: No compose file found! Tried: ${POSSIBLE_FILES[*]}"
    exit 1
fi

echo "Using compose file: $COMPOSE_FILE"

manage_network "$CONTAINER_CMD"

$COMPOSE_CMD -f "$COMPOSE_FILE" up --build -d

echo "Traefik started successfully!"

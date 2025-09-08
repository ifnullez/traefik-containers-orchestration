#!/bin/bash
set -e

source ./container_cmd.sh
source ./compose_cmd.sh

CONTAINER_CMD=$(get_container_cmd)
COMPOSE_CMD=$(get_compose_cmd "$CONTAINER_CMD")

if [[ "$CONTAINER_CMD" == "error" || "$COMPOSE_CMD" == "error" ]]; then
    echo "Neither Podman nor Docker compose is available. Exiting..."
    exit 1
fi

$COMPOSE_CMD stop

echo "Containers stopped successfully!"

#!/bin/bash
source ./bin/container_cmd.sh

CONTAINER_CMD=$(get_container_cmd)

if [[ "$CONTAINER_CMD" == "error" ]]; then
    echo "Neither Podman nor Docker is installed. Exiting..."
    exit 1
fi
$CONTAINER_CMD-compose stop

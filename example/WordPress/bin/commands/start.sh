#!/bin/bash

source ./bin/container_cmd.sh
source ./bin/network.sh

CONTAINER_CMD=$(get_container_cmd)

manage_network $CONTAINER_CMD

if [[ "$CONTAINER_CMD" == "error" ]]; then
    echo "Neither Podman nor Docker is installed. Exiting..."
    exit 1
fi
"$CONTAINER_CMD-compose" up --build -d

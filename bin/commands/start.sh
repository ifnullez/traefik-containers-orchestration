#!/bin/bash

source ./bin/container_cmd.sh
source ./bin/network.sh

CONTAINER_CMD=$(get_container_cmd)
manage_network $CONTAINER_CMD

# Check if the $CONTAINER_CMD-compose.yml file exists
if [ -f "$CONTAINER_CMD-compose.yml" ]; then
    echo "Starting Compose File..."
  "$CONTAINER_CMD-compose" up --build -d
else
  echo "Error: file '$CONTAINER_CMD-compose.yml' not found!"
  exit 1
fi

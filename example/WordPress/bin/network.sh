#!/bin/bash
set -e

NETWORK_NAME="traefik"

manage_network() {
    local CONTAINER_CMD="$1"

    if [[ "$CONTAINER_CMD" == "error" ]]; then
        echo "Neither Podman nor Docker is installed. Exiting..."
        exit 1
    fi

    if "$CONTAINER_CMD" network ls | grep -q "$NETWORK_NAME"; then
        echo "Network '$NETWORK_NAME' already exists."
    else
        echo "Creating network '$NETWORK_NAME'..."
        "$CONTAINER_CMD" network create "$NETWORK_NAME"
        echo "Network '$NETWORK_NAME' successfully created."
    fi
}

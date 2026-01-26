#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/.."

source "$SCRIPT_DIR/container_cmd.sh"

CONTAINER_CMD=$(get_container_cmd)

if [[ "$CONTAINER_CMD" == "error" ]]; then
    echo "Neither Podman nor Docker is installed. Exiting..."
    exit 1
fi

$CONTAINER_CMD image prune -f
$CONTAINER_CMD volume prune -f
$CONTAINER_CMD network prune -f
$CONTAINER_CMD container prune -f
$CONTAINER_CMD system prune -f

echo "Cleanup completed!"

#!/bin/bash
set -e

get_compose_cmd() {
    local CONTAINER_CMD=$1

    if [[ "$CONTAINER_CMD" == "error" ]]; then
        echo "error"
        return 1
    fi

    # Podman
    if [[ "$CONTAINER_CMD" == "podman" ]]; then
        if command -v podman-compose &>/dev/null; then
            echo "podman-compose"
        elif command -v podman &>/dev/null; then
            echo "podman compose"
        else
            echo "error"
            return 1
        fi
    fi

    # Docker
    if [[ "$CONTAINER_CMD" == "docker" ]]; then
        if command -v docker-compose &>/dev/null; then
            echo "docker-compose"
        elif docker compose version &>/dev/null; then
            echo "docker compose"
        else
            echo "error"
            return 1
        fi
    fi
}

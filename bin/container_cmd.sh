#!/bin/bash
set -e

get_container_cmd() {
    if command -v podman &>/dev/null; then
        echo "podman"
    elif command -v docker &>/dev/null; then
        echo "docker"
    else
        echo "error"
        return 1
    fi
}

# Run when executed directly (not sourced)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    get_container_cmd
fi

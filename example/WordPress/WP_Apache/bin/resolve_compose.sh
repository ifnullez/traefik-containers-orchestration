#!/bin/bash
# Thin standalone wrapper used by the Makefile to resolve the compose command.
# Prints the compose command string (e.g. "docker compose") or "error".
set -e

BIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$BIN_DIR/container_cmd.sh"
source "$BIN_DIR/compose_cmd.sh"

CONTAINER_CMD=$(get_container_cmd)
get_compose_cmd "$CONTAINER_CMD"

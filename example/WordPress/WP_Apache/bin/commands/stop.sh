#!/bin/bash
set -e

# ─── Resolve bin dir relative to this script ────────────────────────────────
BIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

source "$BIN_DIR/container_cmd.sh"
source "$BIN_DIR/compose_cmd.sh"

# ─── Usage ───────────────────────────────────────────────────────────────────
usage() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Stops running containers without removing them. Use 'start' to restart them.

Options:
  -h, --help              Show this help message and exit
  -s, --service NAME      Stop a specific service (can be repeated)
  -t, --timeout SECONDS   Shutdown timeout in seconds before sending SIGKILL (default: 10)

Examples:
  $(basename "$0")
  $(basename "$0") -s api
  $(basename "$0") -s api -s worker -t 30
EOF
    exit 0
}

# ─── Argument parsing ─────────────────────────────────────────────────────────
SERVICES=()
TIMEOUT=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        -h|--help)
            usage
            ;;
        -s|--service)
            [[ -z "${2:-}" ]] && { echo "Error: --service requires a value"; exit 1; }
            SERVICES+=("$2")
            shift 2
            ;;
        -t|--timeout)
            [[ -z "${2:-}" ]] && { echo "Error: --timeout requires a value"; exit 1; }
            [[ "$2" =~ ^[0-9]+$ ]] || { echo "Error: --timeout must be a positive integer"; exit 1; }
            TIMEOUT="$2"
            shift 2
            ;;
        *)
            echo "Error: Unknown option: $1"
            usage
            ;;
    esac
done

# ─── Resolve container/compose tooling ───────────────────────────────────────
CONTAINER_CMD=$(get_container_cmd)
COMPOSE_CMD=$(get_compose_cmd "$CONTAINER_CMD")

if [[ "$CONTAINER_CMD" == "error" || "$COMPOSE_CMD" == "error" ]]; then
    echo "Error: Neither Podman nor Docker Compose is available. Exiting..."
    exit 1
fi

# ─── Stop ────────────────────────────────────────────────────────────────────
STOP_CMD=(
    $COMPOSE_CMD stop
    ${TIMEOUT:+--timeout "$TIMEOUT"}
    "${SERVICES[@]}"
)

echo "Running: ${STOP_CMD[*]}"
"${STOP_CMD[@]}"

echo "Containers stopped successfully!"

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

Stops and removes containers, networks, and optionally volumes and images.

Options:
  -h, --help              Show this help message and exit
  -v, --volumes           Remove named volumes declared in the compose file
  --remove-orphans        Remove containers for services not defined in the compose file
  --rmi MODE              Remove images after down: 'all' or 'local' (default: none)
  -t, --timeout SECONDS   Shutdown timeout in seconds before sending SIGKILL (default: 10)

Examples:
  $(basename "$0")
  $(basename "$0") -v
  $(basename "$0") -v --remove-orphans
  $(basename "$0") --rmi local
  $(basename "$0") -v --rmi all -t 30
EOF
    exit 0
}

# ─── Argument parsing ─────────────────────────────────────────────────────────
DOWN_FLAGS=()
TIMEOUT=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        -h|--help)
            usage
            ;;
        -v|--volumes)
            DOWN_FLAGS+=("--volumes")
            shift
            ;;
        --remove-orphans)
            DOWN_FLAGS+=("$1")
            shift
            ;;
        --rmi)
            [[ -z "${2:-}" ]] && { echo "Error: --rmi requires a value: 'all' or 'local'"; exit 1; }
            [[ "$2" == "all" || "$2" == "local" ]] || {
                echo "Error: --rmi value must be 'all' or 'local', got: '$2'"
                exit 1
            }
            DOWN_FLAGS+=("--rmi" "$2")
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

# ─── Down ────────────────────────────────────────────────────────────────────
DOWN_CMD=(
    $COMPOSE_CMD down
    "${DOWN_FLAGS[@]}"
    ${TIMEOUT:+--timeout "$TIMEOUT"}
)

echo "Running: ${DOWN_CMD[*]}"
"${DOWN_CMD[@]}"

echo "Containers stopped and removed successfully!"

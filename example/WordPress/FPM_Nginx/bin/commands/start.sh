#!/bin/bash
set -e

# ─── Resolve bin dir relative to this script ────────────────────────────────
BIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

source "$BIN_DIR/container_cmd.sh"
source "$BIN_DIR/compose_cmd.sh"
source "$BIN_DIR/network.sh"

# ─── Usage ───────────────────────────────────────────────────────────────────
usage() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS] [-- UP_ARGS...]

Options:
  -h, --help              Show this help message and exit
  -s, --service NAME      Start a specific service (can be repeated)
  --build                 Build images before starting containers
  --force-recreate        Recreate containers even if config hasn't changed
  --no-recreate           Do not recreate containers if they already exist
  --no-build              Do not build an image even if it's missing
  --remove-orphans        Remove containers for services not defined in the compose file
  --scale SERVICE=NUM     Scale a service to NUM instances (can be repeated)
  -t, --timeout SECONDS   Shutdown timeout in seconds (default: 10)

Extra arguments after '--' are passed directly to the compose up command.

Examples:
  $(basename "$0")
  $(basename "$0") --build
  $(basename "$0") -s api -s worker
  $(basename "$0") --force-recreate --remove-orphans
  $(basename "$0") --scale worker=3
  $(basename "$0") -s api -- --env-file .env.staging
EOF
    exit 0
}

# ─── Argument parsing ─────────────────────────────────────────────────────────
SERVICES=()
UP_FLAGS=()
SCALE_FLAGS=()
EXTRA_ARGS=()
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
        --build|--force-recreate|--no-recreate|--no-build|--remove-orphans)
            UP_FLAGS+=("$1")
            shift
            ;;
        --scale)
            [[ -z "${2:-}" ]] && { echo "Error: --scale requires a value (e.g. worker=3)"; exit 1; }
            [[ "$2" =~ ^[^=]+=([0-9]+)$ ]] || { echo "Error: --scale value must be in format SERVICE=NUM"; exit 1; }
            SCALE_FLAGS+=("--scale" "$2")
            shift 2
            ;;
        -t|--timeout)
            [[ -z "${2:-}" ]] && { echo "Error: --timeout requires a value"; exit 1; }
            [[ "$2" =~ ^[0-9]+$ ]] || { echo "Error: --timeout must be a positive integer"; exit 1; }
            TIMEOUT="$2"
            shift 2
            ;;
        --)
            shift
            EXTRA_ARGS=("$@")
            break
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

# ─── Validate mutually exclusive flags ───────────────────────────────────────
if [[ " ${UP_FLAGS[*]} " == *" --force-recreate "* && " ${UP_FLAGS[*]} " == *" --no-recreate "* ]]; then
    echo "Error: --force-recreate and --no-recreate are mutually exclusive"
    exit 1
fi

if [[ " ${UP_FLAGS[*]} " == *" --build "* && " ${UP_FLAGS[*]} " == *" --no-build "* ]]; then
    echo "Error: --build and --no-build are mutually exclusive"
    exit 1
fi

# ─── Network setup ───────────────────────────────────────────────────────────
manage_network "$CONTAINER_CMD"

# ─── Start ───────────────────────────────────────────────────────────────────
UP_CMD=(
    $COMPOSE_CMD up -d
    "${UP_FLAGS[@]}"
    "${SCALE_FLAGS[@]}"
    ${TIMEOUT:+--timeout "$TIMEOUT"}
    "${EXTRA_ARGS[@]}"
    "${SERVICES[@]}"
)

echo "Running: ${UP_CMD[*]}"
"${UP_CMD[@]}"

echo "Containers started successfully!"

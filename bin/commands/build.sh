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
Usage: $(basename "$0") [OPTIONS] [-- BUILD_ARGS...]

Options:
  -h, --help          Show this help message and exit
  -s, --service NAME  Build a specific service (can be repeated)
  --no-cache          Build without using cache
  --pull              Always pull a newer version of the base image
  --push              Push service images after build
  --quiet             Do not print progress to stdout

Extra arguments after '--' are passed directly to the compose build command.

Examples:
  $(basename "$0")
  $(basename "$0") --no-cache
  $(basename "$0") -s api -s worker
  $(basename "$0") -- --build-arg ENV=production
  $(basename "$0") --no-cache -s api -- --build-arg VERSION=1.2.3
EOF
    exit 0
}

# ─── Argument parsing ─────────────────────────────────────────────────────────
SERVICES=()
BUILD_FLAGS=()
EXTRA_ARGS=()

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
        --no-cache|--pull|--push|--quiet)
            BUILD_FLAGS+=("$1")
            shift
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

# ─── Network setup ───────────────────────────────────────────────────────────
manage_network "$CONTAINER_CMD"

# ─── Build ───────────────────────────────────────────────────────────────────
BUILD_CMD=(
    $COMPOSE_CMD build
    "${BUILD_FLAGS[@]}"
    "${EXTRA_ARGS[@]}"
    "${SERVICES[@]}"
)

echo "Running: ${BUILD_CMD[*]}"
"${BUILD_CMD[@]}"

echo "Build completed successfully!"

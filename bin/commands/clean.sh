#!/bin/bash
set -e

# ─── Resolve bin dir relative to this script ────────────────────────────────
BIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

source "$BIN_DIR/container_cmd.sh"

# ─── Usage ───────────────────────────────────────────────────────────────────
usage() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Prunes unused container resources. Without any flags, prunes everything.

Options:
  -h, --help          Show this help message and exit
  --images            Prune dangling images
  --volumes           Prune unused volumes
  --networks          Prune unused networks
  --containers        Prune stopped containers
  --all               Prune all of the above (default when no flags given)
  --dry-run           Show what would be removed without actually removing it

Examples:
  $(basename "$0")
  $(basename "$0") --images --volumes
  $(basename "$0") --all
  $(basename "$0") --dry-run
  $(basename "$0") --images --dry-run
EOF
    exit 0
}

# ─── Argument parsing ─────────────────────────────────────────────────────────
PRUNE_IMAGES=false
PRUNE_VOLUMES=false
PRUNE_NETWORKS=false
PRUNE_CONTAINERS=false
DRY_RUN=false

while [[ $# -gt 0 ]]; do
    case "$1" in
        -h|--help)
            usage
            ;;
        --images)
            PRUNE_IMAGES=true
            shift
            ;;
        --volumes)
            PRUNE_VOLUMES=true
            shift
            ;;
        --networks)
            PRUNE_NETWORKS=true
            shift
            ;;
        --containers)
            PRUNE_CONTAINERS=true
            shift
            ;;
        --all)
            PRUNE_IMAGES=true
            PRUNE_VOLUMES=true
            PRUNE_NETWORKS=true
            PRUNE_CONTAINERS=true
            shift
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        *)
            echo "Error: Unknown option: $1"
            usage
            ;;
    esac
done

# ─── Default: prune everything if no specific flags were given ────────────────
if ! $PRUNE_IMAGES && ! $PRUNE_VOLUMES && ! $PRUNE_NETWORKS && ! $PRUNE_CONTAINERS; then
    PRUNE_IMAGES=true
    PRUNE_VOLUMES=true
    PRUNE_NETWORKS=true
    PRUNE_CONTAINERS=true
fi

# ─── Resolve container tooling ────────────────────────────────────────────────
CONTAINER_CMD=$(get_container_cmd)

if [[ "$CONTAINER_CMD" == "error" ]]; then
    echo "Error: Neither Podman nor Docker is installed. Exiting..."
    exit 1
fi

# ─── Prune helper ─────────────────────────────────────────────────────────────
run_prune() {
    local resource="$1"
    local cmd=("$CONTAINER_CMD" "$resource" prune -f)

    if $DRY_RUN; then
        echo "[dry-run] Would run: ${cmd[*]}"
    else
        echo "Pruning ${resource}s..."
        "${cmd[@]}"
    fi
}

# ─── Execute ─────────────────────────────────────────────────────────────────
$DRY_RUN && echo "Dry-run mode: no changes will be made."

$PRUNE_CONTAINERS && run_prune "container"
$PRUNE_IMAGES     && run_prune "image"
$PRUNE_VOLUMES    && run_prune "volume"
$PRUNE_NETWORKS   && run_prune "network"

if $DRY_RUN; then
    echo "Dry-run complete. Nothing was removed."
else
    echo "Cleanup completed successfully!"
fi

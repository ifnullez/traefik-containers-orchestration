#!/bin/bash
set -e

# ─── Config ──────────────────────────────────────────────────────────────────
SSL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/ssl"
INPUT_FILE="$SSL_DIR/sites.conf"
IP_ADDRESS="127.0.0.1"
START_MARKER="# TRAEFIK CUSTOM HOSTS START"
END_MARKER="# TRAEFIK CUSTOM HOSTS END"
DRY_RUN=false

# ─── Usage ───────────────────────────────────────────────────────────────────
usage() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Synchronises /etc/hosts with the DNS entries declared in ssl/sites.conf.
Replaces the managed block between the Traefik markers on every run.
A backup of /etc/hosts is written to /etc/hosts.bak before any change.

Options:
  -h, --help          Show this help message and exit
  --conf PATH         Path to the OpenSSL/sites config (default: ./ssl/sites.conf)
  --ip ADDRESS        IP address to map hostnames to (default: $IP_ADDRESS)
  --dry-run           Print what would be written without modifying /etc/hosts

Examples:
  $(basename "$0")
  $(basename "$0") --dry-run
  $(basename "$0") --ip 192.168.1.100
  $(basename "$0") --conf ./ssl/custom.conf --dry-run
EOF
    exit 0
}

# ─── Argument parsing ─────────────────────────────────────────────────────────
while [[ $# -gt 0 ]]; do
    case "$1" in
        -h|--help)
            usage
            ;;
        --conf)
            [[ -z "${2:-}" ]] && { echo "Error: --conf requires a path"; exit 1; }
            INPUT_FILE="$2"
            shift 2
            ;;
        --ip)
            [[ -z "${2:-}" ]] && { echo "Error: --ip requires an address"; exit 1; }
            IP_ADDRESS="$2"
            shift 2
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

# ─── Validate ─────────────────────────────────────────────────────────────────
if [[ ! -f "$INPUT_FILE" ]]; then
    echo "Error: Config file not found at '$INPUT_FILE'"
    exit 1
fi

# ─── Extract DNS entries from [ alternate_names ] section ────────────────────
DNS_ENTRIES=$(awk '/\[ alternate_names \]/ {flag=1; next} /^\[/ {flag=0} flag && /^DNS/ {print $NF}' "$INPUT_FILE")

if [[ -z "$DNS_ENTRIES" ]]; then
    echo "Error: No DNS entries found in '$INPUT_FILE' under [alternate_names]"
    exit 1
fi

# ─── Build the new managed block ─────────────────────────────────────────────
NEW_BLOCK="$START_MARKER"$'\n'
for DNS in $DNS_ENTRIES; do
    # Skip wildcard domains (e.g. *.example.com)
    [[ "$DNS" == \** ]] && continue

    NEW_BLOCK+="$IP_ADDRESS $DNS"$'\n'
    NEW_BLOCK+="$IP_ADDRESS db.$DNS"$'\n'
    NEW_BLOCK+="$IP_ADDRESS mail.$DNS"$'\n'
done
NEW_BLOCK+="$END_MARKER"

# ─── Dry-run: just print and exit ─────────────────────────────────────────────
if $DRY_RUN; then
    echo "[dry-run] Would replace the managed block in /etc/hosts with:"
    echo ""
    echo "$NEW_BLOCK"
    exit 0
fi

# ─── Apply: backup → strip old block → append new block → replace ────────────
sudo cp /etc/hosts /etc/hosts.bak
echo "Backup written to /etc/hosts.bak"

TMP_FILE=$(mktemp)

# Strip existing managed block
awk -v start="$START_MARKER" -v end="$END_MARKER" '
    $0 == start { skip=1 }
    $0 == end   { skip=0; next }
    skip == 0   { print }
' /etc/hosts > "$TMP_FILE"

# Append new managed block
echo "$NEW_BLOCK" >> "$TMP_FILE"

# Atomically replace /etc/hosts
sudo mv "$TMP_FILE" /etc/hosts

# Restore correct ownership and permissions
if [[ "$(uname -s)" == "Darwin" ]]; then
    sudo chown root:wheel /etc/hosts
else
    sudo chown root:root /etc/hosts
fi
sudo chmod 644 /etc/hosts

echo "Hosts file updated!"

# ─── Flush DNS cache ─────────────────────────────────────────────────────────
OS="$(uname -s)"

if [[ "$OS" == "Darwin" ]]; then
    sudo dscacheutil -flushcache
    sudo killall -HUP mDNSResponder 2>/dev/null || true
    echo "DNS cache flushed (macOS)"
elif command -v resolvectl &>/dev/null; then
    sudo resolvectl flush-caches 2>/dev/null || true
    echo "DNS cache flushed (resolvectl)"
elif command -v systemd-resolve &>/dev/null; then
    sudo systemd-resolve --flush-caches 2>/dev/null || true
    echo "DNS cache flushed (systemd-resolve)"
elif command -v nscd &>/dev/null; then
    sudo nscd -i hosts 2>/dev/null || true
    echo "DNS cache flushed (nscd)"
else
    echo "Warning: Could not detect DNS cache manager. You may need to flush manually."
fi

#!/bin/bash
set -e

# ─── Config ──────────────────────────────────────────────────────────────────
SSL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/ssl"
CONF_FILE="$SSL_DIR/sites.conf"
KEY_FILE="$SSL_DIR/sites.key"
CRT_FILE="$SSL_DIR/sites.crt"
DAYS=3650

# ─── Usage ───────────────────────────────────────────────────────────────────
usage() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Generates a self-signed TLS certificate using the OpenSSL config at ssl/sites.conf.

Options:
  -h, --help          Show this help message and exit
  --days DAYS         Certificate validity in days (default: $DAYS)
  --conf PATH         Path to the OpenSSL config file (default: ./ssl/sites.conf)
  --out-key PATH      Path to write the private key (default: ./ssl/sites.key)
  --out-crt PATH      Path to write the certificate (default: ./ssl/sites.crt)

Examples:
  $(basename "$0")
  $(basename "$0") --days 365
  $(basename "$0") --conf ./ssl/custom.conf
EOF
    exit 0
}

# ─── Argument parsing ─────────────────────────────────────────────────────────
while [[ $# -gt 0 ]]; do
    case "$1" in
        -h|--help)
            usage
            ;;
        --days)
            [[ -z "${2:-}" ]] && { echo "Error: --days requires a value"; exit 1; }
            [[ "$2" =~ ^[0-9]+$ ]] || { echo "Error: --days must be a positive integer"; exit 1; }
            DAYS="$2"
            shift 2
            ;;
        --conf)
            [[ -z "${2:-}" ]] && { echo "Error: --conf requires a path"; exit 1; }
            CONF_FILE="$2"
            shift 2
            ;;
        --out-key)
            [[ -z "${2:-}" ]] && { echo "Error: --out-key requires a path"; exit 1; }
            KEY_FILE="$2"
            shift 2
            ;;
        --out-crt)
            [[ -z "${2:-}" ]] && { echo "Error: --out-crt requires a path"; exit 1; }
            CRT_FILE="$2"
            shift 2
            ;;
        *)
            echo "Error: Unknown option: $1"
            usage
            ;;
    esac
done

# ─── Validate ─────────────────────────────────────────────────────────────────
if ! command -v openssl &>/dev/null; then
    echo "Error: 'openssl' is not installed or not in PATH"
    exit 1
fi

if [[ ! -f "$CONF_FILE" ]]; then
    echo "Error: OpenSSL config not found at '$CONF_FILE'"
    echo "       Create ssl/sites.conf before generating a certificate."
    exit 1
fi

# ─── Generate ─────────────────────────────────────────────────────────────────
mkdir -p "$(dirname "$KEY_FILE")" "$(dirname "$CRT_FILE")"

echo "Generating certificate..."
echo "  Config : $CONF_FILE"
echo "  Key    : $KEY_FILE"
echo "  Cert   : $CRT_FILE"
echo "  Valid  : $DAYS days"

openssl req -config "$CONF_FILE" -x509 -nodes -days "$DAYS" \
    -newkey rsa:2048 -keyout "$KEY_FILE" -out "$CRT_FILE"

echo "Certificate generated successfully!"
echo "Run trust_cert.sh to add it to your system keychain."

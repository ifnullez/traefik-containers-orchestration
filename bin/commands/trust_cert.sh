#!/bin/bash
set -e

# ─── Config ──────────────────────────────────────────────────────────────────
SSL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/ssl"
CRT_FILE="$SSL_DIR/sites.crt"

# ─── Usage ───────────────────────────────────────────────────────────────────
usage() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Installs and trusts the local self-signed certificate in the system keychain.
Must be run after update_cert.sh has generated the certificate.

Options:
  -h, --help          Show this help message and exit
  --cert PATH         Path to the .crt file (default: ./ssl/sites.crt)

Examples:
  $(basename "$0")
  $(basename "$0") --cert ./ssl/custom.crt
EOF
    exit 0
}

# ─── Argument parsing ─────────────────────────────────────────────────────────
while [[ $# -gt 0 ]]; do
    case "$1" in
        -h|--help)
            usage
            ;;
        --cert)
            [[ -z "${2:-}" ]] && { echo "Error: --cert requires a path"; exit 1; }
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
if [[ ! -f "$CRT_FILE" ]]; then
    echo "Error: Certificate not found at '$CRT_FILE'"
    echo "       Run update_cert.sh first to generate it."
    exit 1
fi

# ─── Trust ───────────────────────────────────────────────────────────────────
OS="$(uname -s)"

case "$OS" in
    Darwin)
        echo "Trusting certificate on macOS..."
        sudo security add-trusted-cert -d -r trustRoot \
            -k /Library/Keychains/System.keychain "$CRT_FILE"
        echo "Certificate trusted! You may need to restart your browser."
        ;;
    Linux)
        echo "Trusting certificate on Linux..."
        if command -v update-ca-certificates &>/dev/null; then
            sudo cp "$CRT_FILE" /usr/local/share/ca-certificates/sites.crt
            sudo update-ca-certificates
        elif command -v update-ca-trust &>/dev/null; then
            # RHEL / Fedora / CentOS
            sudo cp "$CRT_FILE" /etc/pki/ca-trust/source/anchors/sites.crt
            sudo update-ca-trust extract
        else
            echo "Error: No supported CA trust tool found (update-ca-certificates / update-ca-trust)"
            exit 1
        fi
        echo "Certificate trusted!"
        ;;
    *)
        echo "Error: Unsupported OS: $OS"
        exit 1
        ;;
esac

#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

IMAGE_NAME="makkyla-test"
CONTAINER_NAME="makkyla-test"
SSH_PORT=2222
KEY_FILE="$SCRIPT_DIR/id_ed25519"

cleanup() {
    echo "Cleaning up..."
    podman rm -f "$CONTAINER_NAME" 2>/dev/null || true
}

# Parse args
DO_CLEANUP=false
for arg in "$@"; do
    case "$arg" in
        --cleanup) DO_CLEANUP=true ;;
    esac
done

# Generate SSH keypair if missing
if [ ! -f "$KEY_FILE" ]; then
    echo "Generating test SSH keypair..."
    ssh-keygen -t ed25519 -f "$KEY_FILE" -N "" -C "makkyla-test"
fi

# Build the container image
echo "Building container image..."
podman build -t "$IMAGE_NAME" "$SCRIPT_DIR"

# Remove any previous test container
podman rm -f "$CONTAINER_NAME" 2>/dev/null || true

# Run the container
echo "Starting container..."
podman run -d --name "$CONTAINER_NAME" -p "$SSH_PORT:22" "$IMAGE_NAME"

# Wait for SSH to become available
echo "Waiting for SSH..."
for i in $(seq 1 30); do
    if ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
           -i "$KEY_FILE" -p "$SSH_PORT" mckyla@127.0.0.1 true 2>/dev/null; then
        echo "SSH is ready."
        break
    fi
    if [ "$i" -eq 30 ]; then
        echo "ERROR: SSH did not become available in time."
        cleanup
        exit 1
    fi
    sleep 1
done

# Run the playbook
echo "Running Ansible playbook..."
ansible-playbook \
    -i "$SCRIPT_DIR/inventory/hosts" \
    "$PROJECT_DIR/full-install.yml" \
    --skip-tags hardware,systemd \
    --diff \
    --limit dedicab \
    --private-key "$KEY_FILE" \
    --ssh-extra-args="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"

RESULT=$?

if [ $RESULT -eq 0 ]; then
    echo ""
    echo "SUCCESS: Playbook completed successfully."
else
    echo ""
    echo "FAILURE: Playbook exited with code $RESULT."
fi

if [ "$DO_CLEANUP" = true ]; then
    cleanup
fi

exit $RESULT

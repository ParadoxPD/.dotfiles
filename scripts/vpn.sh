#!/usr/bin/env bash

set -euo pipefail

ACTION="${1:-}"
shift || true # shift away the action so $@ holds extra args

usage() {
    echo "Usage: $0 {connect|disconnect} [tailscale up args]"
    exit 1
}

if [[ -z "$ACTION" ]]; then
    usage
fi

run_tailscale() {
    local action="$1"
    shift || true
    case "$action" in
    connect)
        # Ensure tailscaled is running
        sudo systemctl start tailscaled

        echo "Fetching available exit nodes..."
        # Get list of exit nodes (those advertising exit-node capability)
        NODES=$(tailscale status --json | jq -r '.Peer | to_entries[] | select(.value.ExitNode) | "\(.value.HostName)\t\(.value.TailscaleIPs[0])"')

        if [[ -z "$NODES" ]]; then
            echo "❌ No exit nodes found in your tailnet."
            exit 1
        fi

        # Use fzf to pick one
        SELECTION=$(echo "$NODES" | fzf --prompt="Select exit node: " --with-nth=1)

        if [[ -z "$SELECTION" ]]; then
            echo "❌ No exit node selected."
            exit 1
        fi

        EXIT_IP=$(echo "$SELECTION" | awk '{print $2}')

        echo "Connecting to exit node: $SELECTION"
        sudo tailscale up --exit-node="$EXIT_IP" --accept-dns=false  --exit-node-allow-lan-access "$@"
        ;;

    disconnect)
        echo "Disconnecting Tailscale..."
        sudo tailscale down
        ;;

    *)
        usage
        ;;
    esac
}

run_tailscale "$ACTION" "$@"

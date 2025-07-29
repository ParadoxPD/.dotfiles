#!/bin/bash

set -e

# Defaults
RUN_DNF=1
RUN_FLATPAK=1
RUN_SNAP=1
DRY_RUN=0
VERBOSE=0

function show_help() {
    cat <<EOF
🛠 System Update Helper Script

Usage:
  ./sysupdate.sh [options]

Options:
  --only-dnf         Only update DNF packages
  --only-flatpak     Only update Flatpak packages
  --only-snap        Only update Snap packages

  --no-dnf           Skip DNF update
  --no-flatpak       Skip Flatpak update
  --no-snap          Skip Snap update

  --dry-run          Show what would be done, without making changes
  --verbose          Print commands before running
  --help             Show this help message

Examples:
  ./sysupdate.sh --only-dnf --dry-run
  ./sysupdate.sh --no-snap --verbose

EOF
}

# Parse flags
for arg in "$@"; do
    case $arg in
        --only-dnf) RUN_DNF=1; RUN_FLATPAK=0; RUN_SNAP=0 ;;
        --only-flatpak) RUN_DNF=0; RUN_FLATPAK=1; RUN_SNAP=0 ;;
        --only-snap) RUN_DNF=0; RUN_FLATPAK=0; RUN_SNAP=1 ;;
        --no-dnf) RUN_DNF=0 ;;
        --no-flatpak) RUN_FLATPAK=0 ;;
        --no-snap) RUN_SNAP=0 ;;
        --dry-run) DRY_RUN=1 ;;
        --verbose) VERBOSE=1 ;;
        --help) show_help; exit 0 ;;
        *)
            echo "❌ Unknown option: $arg"
            echo "Use --help for usage."
            exit 1
            ;;
    esac
done

# Helper to run commands or simulate them
function run() {
    if [[ $DRY_RUN -eq 1 ]]; then
        echo "→ Would run: $*"
    else
        if [[ $VERBOSE -eq 1 ]]; then
            echo "→ Running: $*"
        fi
        eval "$@"
    fi
}

echo -e "\n📦 Starting system update..."

# DNF
if [[ $RUN_DNF -eq 1 ]]; then
    echo -e "\n🟡 Updating system packages (dnf)..."
    run "sudo dnf update -y"
else
    echo -e "\n⏩ Skipping DNF update..."
fi

# Flatpak
if [[ $RUN_FLATPAK -eq 1 ]]; then
    if command -v flatpak &> /dev/null; then
        echo -e "\n🟢 Updating Flatpak packages..."
        run "flatpak update -y"
    else
        echo -e "\n⚠️ Flatpak not installed. Skipping..."
    fi
else
    echo -e "\n⏩ Skipping Flatpak update..."
fi

# Snap
if [[ $RUN_SNAP -eq 1 ]]; then
    if command -v snap &> /dev/null; then
        echo -e "\n🔵 Updating Snap packages..."
        run "sudo snap refresh"
    else
        echo -e "\n⚠️ Snap not installed. Skipping..."
    fi
else
    echo -e "\n⏩ Skipping Snap update..."
fi

echo -e "\n✅ All updates completed!"


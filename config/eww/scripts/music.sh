#!/bin/bash

# This script works with playerctl (supports Spotify, VLC, etc.)
# Install: sudo pacman -S playerctl (Arch) or sudo apt install playerctl (Debian/Ubuntu)

case "$1" in
status)
    playerctl status 2>/dev/null || echo "Stopped"
    ;;
title)
    playerctl metadata title 2>/dev/null || echo ""
    ;;
artist)
    playerctl metadata artist 2>/dev/null || echo ""
    ;;
toggle)
    playerctl play-pause 2>/dev/null
    ;;
next)
    playerctl next 2>/dev/null
    ;;
prev)
    playerctl previous 2>/dev/null
    ;;
*)
    echo "Usage: $0 {status|title|artist|toggle|next|prev}"
    exit 1
    ;;
esac

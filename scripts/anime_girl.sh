#!/bin/bash

# CONFIG
GIF_PATH="$HOME/Pictures/Wallpapers/anime_girl.gif"  # Path to your anime GIF
WEBM_PATH="/tmp/animegirl.webm"
WIDTH=300                                  # Width in px
X_POS=50                                   # X position on screen
Y_POS=700                                  # Y position on screen

# DEPENDENCIES CHECK
for cmd in ffmpeg mpv xdotool wmctrl; do
    if ! command -v $cmd &>/dev/null; then
        echo "$cmd is not installed. Install it first."
        exit 1
    fi
done

# CONVERT GIF to WebM
echo "Converting $GIF_PATH to $WEBM_PATH..."
ffmpeg -y -i "$GIF_PATH" -vf "scale=$WIDTH:-1,format=yuva420p" -c:v libvpx -auto-alt-ref 0 -b:v 1M "$WEBM_PATH"

# PLAY USING MPV
echo "Launching anime girl..."
mpv --loop=inf --no-border --geometry=${X_POS}:${Y_POS} --ontop --no-osc --no-input-default-bindings \
    --no-audio --vo=gpu --profile=low-latency --mute "$WEBM_PATH" &

# WAIT FOR WINDOW TO SPAWN
sleep 1

# MAKE WINDOW CLICK-THROUGH
echo "Making window click-through..."
WIN_ID=$(xdotool search --name "$(basename "$WEBM_PATH")")
xprop -id "$WIN_ID" -f _NET_WM_WINDOW_TYPE 32a -set _NET_WM_WINDOW_TYPE _NET_WM_WINDOW_TYPE_DOCK
wmctrl -ir "$WIN_ID" -b add,below,skip_taskbar,skip_pager

echo "Done! Enjoy your anime mascot"


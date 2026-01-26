#!/bin/bash

function tn_special() {
    if [ "$#" -eq 1 ]; then
        local session="$1"
        if tmux has-session -t "$session" 2>/dev/null; then
            if [ -n "$TMUX" ]; then
                tmux switch-client -t "$session"
            else
                tmux attach-session -t "$session"
            fi
        else
            tmux new-session -A -ds "$session"
            tmux new-window -dt "$session":
            tmux send-keys -t "$session":1 'sudo xremap  /home/pardox/.dev/config/xremap/config.yml --watch' C-m
            tmux send-keys -t "$session":2 '' C-m
            if [ -n "$TMUX" ]; then
                tmux switch-client -t "$session"
            else
                tmux attach-session -t "$session"
            fi
        fi

    else
        echo "you fucked up......"
    fi
}

session="dontclose"
tn_special "$session"

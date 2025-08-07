#!/bin/zsh

#Aliases and functions for tmux
alias tmux="tmux -f $TMUX_CONF_FILE"
alias ts='tn sesh'

function ta() {
    if [ "$#" -eq 1 ]; then
        tmux attach-session -t $1
    elif [ "$#" -eq 0 ]; then
        tmux attach-session
    else
    fi
}

function tn() {
    local session=""
    local win_override=""
    local template=""
    declare -a cmd_override=()

    while [[ "$#" -gt 0 ]]; do
        case "$1" in
        -n | --num-windows)
            win_override="$2"
            shift 2
            ;;
        -c | --command)
            cmd_override+=("$2")
            shift 2
            ;;
        -t | --template)
            template="$2"
            shift 2
            ;;
        *)
            session="$1"
            shift
            ;;
        esac
    done

    if [ -z "$session" ]; then
        echo "No session name provided."
        return 1
    fi

    local config_file="$TMUX_CONF_DIR/.tmux.sessionizer.json"
    local local_config_file="$(pwd)/.tmux.sessionizer.json"
    local config=""
    if [[ -f "$local_config_file" ]]; then
        config=$(<"$local_config_file")
    elif [[ -f "$config_file" ]]; then
        config=$(<"$config_file")
    else
        config='{"defaults": {"windows": 3, "commands": []}}'
    fi

    # Determine template source
    local config_key="${template:-defaults}"

    # Determine number of windows
    local num_windows="$win_override"
    if [ -z "$num_windows" ] || ! [[ "$num_windows" =~ ^[0-9]+$ ]]; then
        num_windows=$(jq -r --arg key "$config_key" '.[$key].windows // 3' <<<"$config")
    fi

    # Get commands
    local -a commands=()
    if [ ${#cmd_override[@]} -gt 0 ]; then
        commands=("${cmd_override[@]}")
    else
        while read -r cmd; do
            commands+=("$cmd")
        done < <(jq -r --arg key "$config_key" '.[$key].commands[]?' <<<"$config")
    fi

    # Create session if not exists
    if ! tmux has-session -t "$session" 2>/dev/null; then
        tmux new-session -d -s "$session"
        for i in $(seq 1 $((num_windows - 1))); do
            tmux new-window -t "$session"
        done

        # Send commands to windows
        if [ -n "$BASH_VERSION" ]; then
            for ((i = 1; i < ${#commands[@]}; i++)); do
                tmux send-keys -t "$session:$((i + 1))" "${commands[$i]}" C-m
            done
        else
            i=1
            for cmd in "${commands[@]}"; do
                tmux send-keys -t "$session:$i" "$cmd" C-m
                ((i++))
            done
        fi
    fi

    if [ -n "$TMUX" ]; then
        tmux switch-client -t "$session"
    else
        tmux attach-session -t "$session"
    fi
}

function tl() {
    local _session_name=$(tmux ls | fzf --height=10 --border --reverse --ansi | sed 's/:.*//')
    if [ ! -z "$_session_name" ]; then
        tn "$_session_name" "$@"
    else
        echo "why you do this? huh ??"
    fi

}
function tk() {
    local _session_name=$(tmux ls | fzf --height=10 --border --reverse --ansi | sed 's/:.*//')
    if [ ! -z "$_session_name" ]; then
        tmux kill-session -t "$_session_name"
    else
        echo "why you do this? huh ??"
    fi

}
function t() {
    local out_dir="$(fd . ~/Documents ~/Desktop ~/Documents/Projects ~/ ~/.dev/config --type=d --hidden --exclude .git --max-depth 3 | sort | uniq | fzf --preview 'eza --tree --level=4 --color=always {} | head -200')"
    if [ ! -z "$out_dir" ]; then
        local curr_dir=$(pwd)
        cd $out_dir
        local tmux_session_name=$(basename $out_dir)
        tmux_session_name="${tmux_session_name//./_}"
        tn $tmux_session_name "$@"
        cd "$curr_dir"

    else
        echo "you fucked up"
    fi
}

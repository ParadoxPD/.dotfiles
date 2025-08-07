#!/usr/bin/env zsh

#Aliases and functions for tmux
alias tmux="tmux -f $TMUX_CONF_FILE"
alias ts='tn sesh'

config_file="${TMUX_CONF_DIR:-${XDG_CONFIG_HOME:-$HOME/.config}}/.tmux.sessionizer.json"
config=""
if [[ -f "$config_file" ]]; then
    config=$(<"$config_file")
else
    config='{"defaults": {"windows": 3, "commands": [], "search_dirs" : ["~/Documents", "~/Desktop" ,"~/"] } }'
fi

function sanity_check() {
    if ! command -v tmux &>/dev/null; then
        echo "tmux is not installed. Please install it first."
        exit 1
    fi

    if ! command -v fzf &>/dev/null; then
        echo "fzf is not installed. Please install it first."
        exit 1
    fi
    
    if ! command -v jq &>/dev/null; then
        echo "jq is not installed. Please install it first."
        exit 1
    fi
}

function ta() {
    sanity_check
    if [ "$#" -eq 1 ]; then
        tmux attach-session -t $1
    elif [ "$#" -eq 0 ]; then
        tmux attach-session
    else
    fi
}

function tn() {
    sanity_check
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

    local local_config_file="$(pwd)/.tmux.sessionizer.json"
    if [[ -f "$local_config_file" ]]; then
        config=$(<"$local_config_file")
    fi



    # Determine template source
    local config_key="${template:-defaults}"

    # Determine number of windows
    local num_windows="$win_override"
    if [ -z "$num_windows" ] || ! [[ "$num_windows" =~ ^[0-9]+$ ]]; then
        num_windows=$(jq -r --arg key "$config_key" '
            if .[$key].windows then .[$key].windows
            else .defaults.windows end // 3
        ' <<<"$config")
    fi

    # Get commands
    local -a commands=()
    if [ ${#cmd_override[@]} -gt 0 ]; then
        commands=("${cmd_override[@]}")
    else
        while read -r cmd; do
            commands+=("$cmd")
        done < <(jq -r --arg key "$config_key" '
            if .[$key].commands then .[$key].commands[]
            else .defaults.commands[] end
        ' <<<"$config")
    fi


    # Create session if not exists
    if ! tmux has-session -t "$session" 2>/dev/null; then
        tmux new-session -d -s "$session"
        for i in $(seq 1 $((num_windows - 1))); do
            tmux new-window -t "$session"
        done

        # Send commands to windows
        for ((i = 1; i <= ${#commands[@]}; i++)); do
            tmux send-keys -t "$session:$i" "${commands[$i]}" C-m
        done
    fi

    if [ -n "$TMUX" ]; then
        tmux switch-client -t "$session:1"
    else
        tmux attach-session -t "$session:1"
    fi
}

function tl() {
    sanity_check
    local _session_name=$(tmux ls | fzf --height=10 --border --reverse --ansi | sed 's/:.*//')
    if [ ! -z "$_session_name" ]; then
        tn "$_session_name" "$@"
    else
        echo "why you do this? huh ??"
    fi

}

function tk() {
    sanity_check
    local _session_name=$(tmux ls | fzf --height=10 --border --reverse --ansi | sed 's/:.*//')
    if [ ! -z "$_session_name" ]; then
        tmux kill-session -t "$_session_name"
    else
        echo "why you do this? huh ??"
    fi

}

function t() {
    local template=""
    local all_args=("$@")
    while [[ "$#" -gt 0 ]]; do
        case "$1" in
        -t|--template)
            template="$2"
            break
            ;;
        *)
            shift
            ;;
        esac
    done

    local config_key="${template:-defaults}"
    local search_dirs=()
    local search_dirs=($(jq -r --arg key "$config_key" '
      if .[$key].search_dirs then .[$key].search_dirs[]
      else .defaults.search_dirs[] end
    ' <<<"$config"))

    # Fallback if empty
    if [[ ${#search_dirs[@]} -eq 0 ]]; then
        echo "Add search_dirs to the config"
        search_dirs=(~/Documents ~/Desktop ~/)
    fi


    # Expand ~ manually
    for ((i = 1; i <= ${#search_dirs[@]}; i++)); do
        search_dirs[$i]="${search_dirs[$i]/\~/$HOME}"
    done


    # Build fd arguments
    local fd_args=()
    for dir in "${search_dirs[@]}"; do
        fd_args+=("$dir")
    done

    local out_dir
    out_dir="$(fd . "${fd_args[@]}" --type=d --hidden --exclude .git --max-depth 3 \
        | sort | uniq \
        | fzf --preview 'eza --tree --level=4 --color=always {} | head -200')"
    
    if [ ! -z "$out_dir" ]; then
        local curr_dir=$(pwd)
        cd $out_dir
        local tmux_session_name=$(basename $out_dir)
        tmux_session_name="${tmux_session_name//./_}"
        tn $tmux_session_name "${all_args[@]}"
        cd "$curr_dir"
    else
        echo "you fucked up"
    fi
}

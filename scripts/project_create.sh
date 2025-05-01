#!/bin/bash

# Define color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

#Define flags and other important shit
debug_flag=0
old_stty=$(stty -g)

#define all the functions
function parse_flags() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
        -d | --debug)
            debug_flag=1
            ;;
        -h | --help)
            echo "Usage: $0 [-d | --debug]"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Usage: $0 [-d | --debug]"
            exit 1
            ;;
        esac
        shift # move to next argument
    done
}

# ASCII Art Banner
function animate() {
    echo -e "${CYAN}"
    if [ "$debug_flag" -eq 1 ]; then
        echo
        cat <<"EOF"

        __________                          
        \____    /____   ____   _______  ___
          /     // __ \ /    \ /  _ \  \/  /
         /     /\  ___/|   |  (  <_> >    < 
        /_______ \___  >___|  /\____/__/\_ \
                \/   \/     \/            \/
        
EOF
    else
        while IFS= read -r line; do
            echo -n "      "
            for ((i = 0; i < ${#line}; i++)); do
                echo -n "${line:$i:1}"
                sleep 0.005
            done
            echo
        done <<"EOF"

            __________                          
            \____    /____   ____   _______  ___
              /     // __ \ /    \ /  _ \  \/  /
             /     /\  ___/|   |  (  <_> >    < 
            /_______ \___  >___|  /\____/__/\_ \
                    \/   \/     \/            \/
            
EOF
    fi

    echo -e "${NC}"
}

color_echo() {
    local color="$1"
    shift
    echo -e "${!color}$* ${NC}"
}

is_safe_relative_path() {
    local path="$1"
    local full_path

    # Expand ~ to home
    full_path=$(realpath -m "$path" 2>/dev/null)

    # If realpath fails or is empty, reject
    [[ -z "$full_path" ]] && return 1

    # Reject paths starting with ~, ~/Documents, etc.
    local home_dir="$HOME"
    local forbidden=(
        "$home_dir"
        "$home_dir/"
        "$home_dir/Desktop"
        "$home_dir/Documents"
        "$home_dir/Downloads"
        "$home_dir/Music"
        "$home_dir/Pictures"
        "$home_dir/Videos"
    )

    for bad in "${forbidden[@]}"; do
        if [[ "$full_path" == "$bad" ]]; then
            return 1
        fi
    done
    return 0
}

function exit_process() {
    echo
    echo -e "${RED}"
    if [[ "$#" -eq 2 && -d "$2" ]] && is_safe_relative_path "$2"; then
        cd ..
        echo "Deleting project directory : $2"
        #SCARY!!!!!
        rm -r $2
    fi
    echo -e "$1"
    echo -e "${NC}"
    stty "$old_stty"
    exit 1

}

function tn() {
    if [ "$#" -eq 1 ]; then
        tmux new-session -A -ds $1
        tmux new-window -d
        tmux new-window -d
        tmux attach-session -d -t $1

    else
        color_echo RED "you shouldnt be here... what did you do, how did you get here"
    fi
}

sessionize() {
    local tmux_session_name=$(basename $1)
    tmux_session_name="${tmux_session_name//./_}"
    tn $tmux_session_name
}

expand_path() {
    local input="$1"
    # First expand tilde if present
    if [[ "$input" == ~* ]]; then
        input=$(eval echo "$input")
    fi

    # Then normalize the path (make absolute and resolve symlinks)
    if [[ "$input" == /* ]]; then
        realpath -m "$input"
    else
        realpath -m "$(pwd)/$input"
    fi
}

# Function for reading input with ESC key detection
special_read() {
    local prompt="$1"
    local __varname="$2"
    local default_value="${3:-}"
    local exit_on_esc="${4:-true}" # Fourth parameter: true=exit script, false=just return

    # Show prompt
    echo -e "$prompt   "

    # Save terminal settings
    local old_stty
    old_stty=$(stty -g)
    # Set terminal to capture escape sequences
    stty raw -echo

    # Read a single character to check for ESC
    local char
    IFS= read -r -n1 char

    # Check if ESC was pressed
    if [[ "$char" == $'\e' ]]; then
        # Reset terminal
        stty "$old_stty"
        echo

        if [[ "$exit_on_esc" == "true" ]]; then
            exit_process "Escape pressed. Exiting gracefully." $project_dir
        else
            printf -v "$__varname" ""
            return 1 # Just return from function
        fi
    else
        # Rest of the function remains the same...
        stty "$old_stty"

        local input
        if [[ -n "$char" && "$char" != $'\r' && "$char" != $'\n' ]]; then
            input="$char"
            read -e -i "$input" input
            printf -v "$__varname" "%s" "$input"
            return 0
        else
            printf -v "$__varname" "%s" "$default_value"
            echo
            return 0
        fi

    fi
}

initialize_project() {
    # Initialize Git repository
    color_echo CYAN "Initializing Git repository..."
    git init

    # Initialize according to project type
    local selected_type=$1
    case $selected_type in
    "Node.js")
        color_echo CYAN "Initializing Node.js project..."
        npm init -y
        ;;
    "Python")
        color_echo CYAN "Initializing Python project with uv..."
        uv venv
        ;;
    "Java")
        color_echo CYAN "Java project selected. No extra initialization."
        ;;
    "None")
        color_echo CYAN "Other project selected. No extra initialization."
        ;;
    *)
        color_echo RED "How?"
        ;;
    esac

    local gitignore_choice=$2
    if [[ "$gitignore_choice" =~ ^[Yy]$ ]]; then
        case $selected_type in
        "Node.js")
            echo -e "node_modules/\n.env" >.gitignore
            ;;
        "Python")
            echo -e "__pycache__/\n.env\n.venv/" >.gitignore
            ;;
        "Java")
            echo -e "bin/\n*.class" >.gitignore
            ;;
        "Other")
            touch .gitignore
            ;;
        esac
        color_echo GREEN "Created .gitignore"
    else
        color_echo CYAN "Skipping .gitignore creation."
    fi

    local readme_choice=$3
    if [[ "$readme_choice" =~ ^[Yy]$ ]]; then
        echo "# $project_name" >README.md
        color_echo GREEN "Created README.md"
    else
        color_echo CYAN "Skipping README.md creation."
    fi

}

set_licence() {

    local selected_licence=$1

    # Mapping display name -> GitHub API ID
    declare -A licence_api_ids=(
        ["MIT"]="mit"
        ["Apache 2.0"]="apache-2.0"
        ["GPL v3"]="gpl-3.0"
        ["BSD 2-Clause"]="bsd-2-clause"
        ["BSD 3-Clause"]="bsd-3-clause"
        ["LGPL v3"]="lgpl-3.0"
        ["AGPL v3"]="agpl-3.0"
        ["MPL 2.0"]="mpl-2.0"
        ["Unlicense"]="unlicense"
        ["CC0 1.0"]="cc0-1.0"
        ["EPL 2.0"]="epl-2.0"
    )
    if [[ -n "$selected_licence" && "$selected_licence" != "None" ]]; then
        color_echo YELLOW "Fetching license text for ${selected_licence}..."

        # Convert to lowercase for GitHub API (most licenses are lowercase ids)
        api_id="${licence_api_ids[$selected_licence]}"

        if [[ -z "$api_id" ]]; then
            color_echo RED "Error: No API mapping found for '$selected_licence'."
        else

            # Fetch license text from GitHub API
            license_text=$(curl -s "https://api.github.com/licenses/$api_id" | jq -r '.body')

            if [[ -n "$license_text" && "$license_text" != "null" ]]; then
                echo "$license_text" >LICENSE
                color_echo GREEN "LICENSE file created using $selected_licence."
            else
                color_echo RED "Failed to fetch license text. The identifier may not match GitHub API format."
            fi
        fi
    else
        color_echo YELLOW "No license will be applied."
    fi
}

#Actual start of the script
parse_flags "$@"
animate

color_echo YELLOW "Enter the path where you want to create the project:"
base_path="$(fd . ~/ ~/Documents ~/Desktop ~/Documents/Projects --type=d --hidden --exclude .git --min-depth 0 --max-depth 3 | uniq | sort | fzf --height=20 --border --reverse --ansi)"
#special_read "${YELLOW}Enter the path where you want to create the project (Empty for current directory):${NC}" base_path "$(pwd)"
if [[ -z "$base_path" ]]; then
    exit_process "Escape pressed. Exiting gracefully."
fi

base_path=$(expand_path "$base_path")
color_echo GREEN "Base Directory : $base_path"

special_read "${YELLOW}Enter the project name:${NC}" project_name ""
# Validate project_name
if [[ -z "$project_name" ]]; then
    echo -e "${RED}\nProject name cannot be empty. Exiting.${NC}"
    exit 1
fi

color_echo GREEN "Project Name : $project_name"
# Create the directory
# Expand ~ manually if needed
project_dir="$base_path/$project_name"
if [ -d "$project_dir" ]; then
    exit_process "The Project : '$project_dir' already exists. Exiting script."
fi

mkdir -p "$project_dir" || {
    exit_process "Failed to create directory. Exiting."
}

# Check if project_dir is empty (extremely rare now)
if [[ -z "$project_dir" ]]; then
    exit_process "Project directory is empty. Exiting."
fi

cd "$project_dir" || {
    exit_process "Failed to cd into project directory. Exiting." $project_dir
}

# Project types
types=("Node.js" "Python" "Java" "None")

# Use fzf for selection with fancy options
selected_type=$(printf "%s\n" "${types[@]}" | fzf --prompt="Select project type: " --height=10 --border --reverse --ansi)

if [[ -z "$selected_type" ]]; then
    exit_process "No project type selected. Exiting." $project_dir
fi

color_echo GREEN "Selected project type: $selected_type"

special_read "${YELLOW}Do you want to create a README.md? (Y/N) [${CYAN}default: N${YELLOW}]${NC}" readme_choice ""
special_read "${YELLOW}Do you want to create a .gitignore? (Y/N) [${CYAN}default: N${YELLOW}]${NC}" gitignore_choice ""
initialize_project $selected_type $gitignore_choice $readme_choice

# GitHub license identifiers
licence_types=(
    "MIT"
    "Apache-2.0"
    "GPL-3.0"
    "BSD-2-Clause"
    "BSD-3-Clause"
    "LGPL-3.0"
    "AGPL-3.0"
    "MPL-2.0"
    "Unlicense"
    "CC0-1.0"
    "EPL-2.0"
    "None"
)

# Let user pick a license using fzf
selected_licence=$(printf "%s\n" "${licence_types[@]}" | fzf --prompt="Select a license (None for no license): " --height=10 --border --reverse --ansi)

set_licence "$selected_licence"

color_echo GREEN "Project setup complete at ${project_dir}."

special_read "${YELLOW}Do you want to create to create tmux session? (Y/N) [${CYAN}default: Y${YELLOW}]${NC}" session_choice ""
if [[ "$session_choice" =~ ^[Nn]$ ]]; then
    color_echo RED "Skipping session creation."
else
    sessionize $project_dir
fi

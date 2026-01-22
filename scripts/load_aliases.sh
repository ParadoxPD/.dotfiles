function get_dir() {
    local __varname="$1"
    local dir
    dir="$(fd --type=d --hidden --exclude .git --exclude node_modules --exclude .cache --max-depth 10 . ~ | fzf --preview 'eza --tree --level=4 --color=always {} | head -200')"
    printf -v "$__varname" "%s" "$dir"
    return 0
}

# some aliases
alias zshconfig="~/.zshrc"
alias bashconfig="~/.bashrc"

#SCARY!!!!
alias cd='z'
alias cdold='cd'
function c() {
    local out_dir
    get_dir out_dir
    if [[ -n "$out_dir" ]]; then
        cd "$out_dir" || return
    else
        echo "you fucked up"
    fi

}

function n() {
    if [[ -n "$1" ]]; then
        nautilus -w "$1" &
    else
        local out_dir
        get_dir out_dir

        if [[ -n "$out_dir" ]]; then
            nautilus -w "$out_dir" &
        else
            echo "you fucked up"
        fi
    fi

}
alias cat='bat'
alias grep='rg'
alias fk='thefuck'
alias rmt='rmtrash'
alias rmdt='rmdirtrash'
alias tree='tre'

#Aliases and functions for eza
alias ls='eza -a --icons --color=always'
alias ll='eza -l --icons --color=always'
alias la='eza -la --icons --color=always'
alias lt='eza --tree --icons --color=always'
alias l='eza -la --icons --color=always'

#Aliases and functions for fzf
function f() {
    local out_dir
    out_dir="$(fd --type=d --hidden --strip-cwd-prefix --exclude .git --max-depth 4 | fzf --preview 'eza --tree --level=4 --color=always {} | head -200')"

    if [[ -n "$out_dir" ]]; then
        nvim "$out_dir"
    else
        echo "you fucked up"
    fi
}

function ff() {
    local out_file
    out_file="$(fd --type=f --hidden --strip-cwd-prefix --exclude .git | fzf --preview 'bat -n --color=always --line-range :500 {}')"

    if [[ -n "$out_file" ]]; then
        nvim "$out_file"
    else
        echo "you fucked up"
    fi

}

#Aliases and functions for vim and code
alias vi="nvim"
alias vim="nvim"
function +() {
    if [ "$#" -eq 0 ]; then
        nvim .
    else
        nvim "$1"
    fi
}

function +c() {
    if [ "$#" -eq 0 ]; then
        code .
    else
        code "$1"
    fi

}

source "$DEVSRC/scripts/tmux.sessionizer.sh"

#Aliases and functions for git
alias gs='git status'
alias gd='git diff'
function push() {
    if [ "$#" -eq 2 ]; then
        git add .
        git commit -m "$2"
        git push origin "$1"
    else
        echo "Wrong Arguments Bi7ch......."
    fi

}

function wip() {
    if [ "$#" -eq 1 ]; then
        git add .
        git commit -m "Bug Fixes and Refactoring"
        git push origin "$1"
    elif [ "$#" -eq 0 ]; then
        git add .
        git commit -m "Bug Fixes and Refactoring"
        git push origin main
    else
        echo "Wrong Arguments Bi7ch........."
    fi

}

function lpush() {
    if [ "$#" -eq 1 ]; then
        git add .
        git commit -m "$1"
    else
        echo "Wrong Arguments Bi7ch......."
    fi

}

function p() {
    project_create.sh "$@"
}

function k() {
    showmekey.sh
}

#Qol????
function dnff() {
    local pkg_list
    local selected_pkgs
    pkg_list=$(dnf repoquery --available --qf '%{name} - %{summary}\n')
    selected_pkgs="$(echo $pkg_list | fzf --multi --preview='dnf info $(echo {} | sed "s/ - .*//")' --preview-window=down:75% | sed 's/ - .*//')"
    if [ -n "$selected_pkgs" ]; then
        echo "Selected packages:"
        echo "$selected_pkgs"
        echo -n "Proceed to install? [y/N]: "
        read -r confirm
        if [[ "$confirm" =~ ^[Yy]$ ]]; then
            echo "$selected_pkgs" | xargs sudo dnf install
        fi
    else
        echo "you fucked up"
    fi

}

alias ..='cd ..'
alias ...='cd ../..'

#fuckall aliases because I cant type
alias clea=clear
alias lclea=clear
alias lcear=clear
alias lcea=clear
alias rclea=clear
alias rclear=clear
alias cls=clear

#tts stuff
function matushka() {
    curl -X POST http://localhost:8080/speak \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer supersecrettoken" \
        -d "{
      \"text\": \"$1\",
      \"voice\": \"russian-female\"
    }"
}

function mario() {
    curl -X POST http://localhost:8080/speak \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer supersecrettoken" \
        -d "{
      \"text\": \"$1\",
      \"voice\": \"italian-male\"
    }"
}

function scam() {
    curl -X POST http://localhost:8080/speak \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer supersecrettoken" \
        -d "{
      \"text\": \"$1\",
      \"voice\": \"indian-male\"
    }"
}

function bmw() {
    curl -X POST http://localhost:8080/speak \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer supersecrettoken" \
        -d "{
      \"text\": \"$1\",
      \"voice\": \"german-female\"
    }"
}

source ~/.dev/scripts/gdb_stuff.sh

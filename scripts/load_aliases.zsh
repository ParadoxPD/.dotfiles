# some aliases
alias zshconfig="~/.zshrc"
#SCARY!!!!
alias cd='z'
#alias cdold='cd'
alias cat='bat'
alias grep='rg'
alias fk='thefuck'
alias rmt='rmtrash'
alias rmdt='rmdirtrash'

#Aliases and functions for eza
alias ls='eza -a --icons --color=always'
alias ll='eza -l --icons --color=always'
alias la='eza -la --icons --color=always'
alias lt='eza --tree --icons --color=always'
alias l='eza -la --icons --color=always'

#Aliases and functions for fzf
function f(){
  local out_dir="$(fd --type=d --hidden --strip-cwd-prefix --exclude .git --max-depth 4 | fzf --preview 'eza --tree --level=4 --color=always {} | head -200')"

  if [ ! -z "$out_dir" ]
  then
    nvim $out_dir
  else
    echo "you fucked up"
  fi
}

function ff(){
  local out_file="$(fd --type=f --hidden --strip-cwd-prefix --exclude .git | fzf --preview 'bat -n --color=always --line-range :500 {}')"

  if [ ! -z "$out_file" ]
  then
    nvim $out_file
  else
    echo "you fucked up"
  fi

}


#Aliases and functions for vim and code
alias vi="nvim"
alias vim="nvim"
function +(){ 
  if [ "$#" -eq 0 ]
  then
    nvim .
  else
    nvim $1
  fi
}

function +c(){
 if [ "$#" -eq 0 ]
  then
    code .
  else
    code $1
  fi

}


#Aliases and functions for tmux
alias tmux="tmux -f $TMUX_CONF_FILE"
function ta(){
  if [ "$#" -eq 1 ]
  then
    tmux attach-session -t $1
  elif [ "$#" -eq 0 ] 
  then
    tmux attach-session
  else	
  fi
}
alias ts='tn sesh'
function tn(){
  if [ "$#" -eq 1 ]
  then
    local session="$1"
    if tmux has-session -t "$session" 2>/dev/null
    then
      if [ -n "$TMUX" ]
      then
	tmux switch-client -t "$session"
      else
	tmux attach-session -t "$session"
      fi
    else
      tmux new-session -A -ds "$session"
      tmux new-window -dt "$session":
      tmux new-window -dt "$session":
      if [ -n "$TMUX" ]
      then
	tmux switch-client -t "$session"
      else
	tmux attach-session -t "$session"
      fi
    fi
  
  else
    echo "you fucked up......"
  fi
}
function tl(){
  local _session_name=$(tmux ls | fzf --height=10 --border --reverse --ansi | sed 's/:.*//')
 if [ ! -z "$_session_name" ]
  then
  tn "$_session_name"
  else
    echo "why you do this? huh ??"
  fi

}
function t(){
  local out_dir="$(fd . ~/Documents ~/Desktop ~/Documents/Projects ~/ ~/.dev/config --type=d --hidden --exclude .git --max-depth 3 | sort | uniq | fzf --preview 'eza --tree --level=4 --color=always {} | head -200')"  
  if [ ! -z "$out_dir" ]
  then
    local curr_dir=$(pwd)
    cd $out_dir
    local tmux_session_name=$(basename $out_dir)
    tmux_session_name="${tmux_session_name//./_}"
    tn $tmux_session_name
    cd "$curr_dir"

  else
    echo "you fucked up"
  fi
}

#Aliases and functions for git
alias gs='git status'
alias gd='git diff'
function push(){
  if [ "$#" -eq 2 ]
  then
    git add .
    git commit -m $2
    git push origin $1
  else
    echo "Wrong Arguments Bi7ch......."
  fi

}

function wip(){
  if [ "$#" -eq 1 ]
  then
    git add .
    git commit -m "Bug Fixes and Refactoring"
    git push origin $1
  elif [ "$#" -eq 0 ] 
  then
    git add .
    git commit -m "Bug Fixes and Refactoring"
    git push origin main
  else 
    echo "Wrong Arguments Bi7ch........."
  fi

}

function lpush(){
  if [ "$#" -eq 1 ]
  then
    git add .
    git commit -m $1
  else
    echo "Wrong Arguments Bi7ch......."
  fi

}

function p(){
  project_create.sh "$@"
}

function k(){
  showmekey.sh
}

#Qol????
function dnff(){
  local pkg_list=$(dnf repoquery --available --qf '%{name} - %{summary}\n')
  local selected_pkgs="$(echo $pkg_list | fzf --multi --preview='dnf info $(echo {} | sed "s/ - .*//")' --preview-window=down:75% | sed 's/ - .*//')"
  if [ -n "$selected_pkgs" ]; then
    echo "Selected packages:"
    echo "$selected_pkgs"
    echo -n "Proceed to install? [y/N]: "
    read confirm
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


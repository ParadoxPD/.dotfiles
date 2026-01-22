# === ZSH Startup + Prompt Profiler (logging version) ===
ZSH_PROFILE_LOG="$HOME/.zsh_profile_log"

# Reset log at each shell start
: > "$ZSH_PROFILE_LOG"


# Start timer *before* the prompt is drawn
prompt_timer_precmd() {
  _prompt_start=$(date +%s%N)
}

# Stop timer *right after* prompt drawing finishes
prompt_timer_ps1() {
  local end=$(date +%s%N)
  local elapsed_ms=$(( (end - _prompt_start) / 1000000 ))
  printf "\n\n\n%6d ms  prompt render\n" "$elapsed_ms" >> "$ZSH_PROFILE_LOG"
}

autoload -Uz add-zsh-hook
add-zsh-hook precmd prompt_timer_precmd   # fires before prompt is built
add-zsh-hook preexec prompt_timer_ps1     # fires after prompt is drawn

_zsh_prof_start=$(date +%s%N)
_zsh_prof_last=$_zsh_prof_start

_prof() {
  local now=$(date +%s%N)
  local elapsed_ms=$(( (now - _zsh_prof_last) / 1000000 ))
  printf "%6d ms  %s\n" "$elapsed_ms" "$1" >> "$ZSH_PROFILE_LOG"
  _zsh_prof_last=$now
}

_prof "Start of .zshrc"
zmodload zsh/zprof

#Source the environment variables
source ~/.dev/scripts/load_env.sh
_prof "Loaded env from .dev"

ZSH_THEME="robbyrussell"

plugins=(
	git
	zsh-autosuggestions
)

source $ZSH/oh-my-zsh.sh
_prof "Sourced oh my zsh"
#source ~/.zsh_prompt_profiler.zsh

# History configurations
HISTFILE=~/.zsh_history
HISTSIZE=1000
SAVEHIST=2000
setopt hist_expire_dups_first # delete duplicates first when HISTFILE size exceeds HISTSIZE
setopt hist_ignore_dups       # ignore duplicated commands history list
setopt hist_ignore_space      # ignore commands that start with space
setopt hist_verify            # show command with history expansion to user before running it
#setopt share_history         # share command history data



#load aliases and functions
source ~/.dev/scripts/load_aliases.sh
_prof "Sourced aliases"

# enable auto-suggestions based on the history
if [ -f /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then
    . /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
    # change suggestion color
    ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#999'
fi

# enable command-not-found if installed
if [ -f /etc/zsh_command_not_found ]; then
    . /etc/zsh_command_not_found
fi

source /home/paradox/.dev/zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source /home/paradox/.dev/zsh/zsh-autocomplete/zsh-autocomplete.plugin.zsh
_prof "Sourced plugins"


eval "$(zoxide init zsh)"
eval "$(thefuck --alias)"
eval "$(fzf --zsh)"

# -- Use fd instead of fzf --
export FZF_DEFAULT_COMMAND="fd --hidden --strip-cwd-prefix --exclude .git"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fd --type=d --hidden --strip-cwd-prefix --exclude .git"

# Use fd (https://github.com/sharkdp/fd) for listing path candidates.
# - The first argument to the function ($1) is the base path to start traversal
# - See the source code (completion.{bash,zsh}) for the details.
_fzf_compgen_path() {
  fd --hidden --exclude .git . "$1"
}

# Use fd to generate the list for directory completion
_fzf_compgen_dir() {
  fd --type=d --hidden --exclude .
}

show_file_or_dir_preview="if [ -d {} ]; then eza --tree --color=always {} | head -200; else bat -n --color=always --line-range :500 {}; fi"
export FZF_CTRL_T_OPTS="--preview 'bat -n --color=always --line-range :500 {}'"
export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always {} | head -200'"

# Advanced customization of fzf options via _fzf_comprun function
# - The first argument to the function is the name of the command.
# - You should make sure to pass the rest of the arguments to fzf.
_fzf_comprun() {
  local command=$1
  shift

  case "$command" in
    cd)           fzf --preview 'eza --tree --color=always {} | head -200' "$@" ;;
    export|unset) fzf --preview "eval 'echo $'{}"         "$@" ;;
    ssh)          fzf --preview 'dig {}'                   "$@" ;;
    *)            fzf --preview "bat -n --color=always --line-range :500 {}" "$@" ;;
  esac
}


export PATH="$PATH:$DEVSRC/bin:$DEVSRC/neovim/bin:$DEVSRC/go/bin:$DEVSRC/zig:$DEVSRC/node/bin:$DEVSRC/rust/.cargo/bin:$DEVSRC/php/herd-lite/bin:$HOME/.local/bin:$FLUTTER_SRC:$ANDROID_SDK_ROOT:$ANDROID_PLATFORM_TOOLS:$ANDROID_CMDLINE_TOOLS:$ANDROID_EMULATOR_ROOT:$HOME/go/bin:$DEVSRC/scripts"
_prof "Set path"


source "$DEVSRC/rust/.cargo/env"
_prof "Sourced cargo env"


#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
[[ -s "$DEVSRC/.sdkman/bin/sdkman-init.sh" ]] && source "$DEVSRC/.sdkman/bin/sdkman-init.sh"
_prof "Sourced sdkman"


[[ ! -r '/home/paradox/.dev/.opam/opam-init/init.zsh' ]] || source '/home/paradox/.dev/.opam/opam-init/init.zsh' > /dev/null 2> /dev/null
_prof "Sourced opam"


# End of file
_prof "End of .zshrc"
zprof >> "$ZSH_PROFILE_LOG" 



# opencode
export PATH=/home/paradox/.opencode/bin:$PATH

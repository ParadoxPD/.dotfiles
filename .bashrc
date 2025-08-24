# .bashrc

source ~/.dev/scripts/load_env.sh
source ~/.dev/scripts/load_aliases.sh
# Source global definitions
if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi

export PATH="$PATH:$DEVSRC/bin:$DEVSRC/neovim/bin:$DEVSRC/go/bin:$DEVSRC/zig:$DEVSRC/node/bin:$DEVSRC/rust/.cargo/bin:$DEVSRC/php/herd-lite/bin:$HOME/.local/bin:$FLUTTER_SRC:$ANDROID_SDK_ROOT:$ANDROID_PLATFORM_TOOLS:$ANDROID_CMDLINE_TOOLS:$ANDROID_EMULATOR_ROOT:$HOME/go/bin:$DEVSRC/scripts"

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
[[ -s "$DEVSRC/.sdkman/bin/sdkman-init.sh" ]] && source "$DEVSRC/.sdkman/bin/sdkman-init.sh"

source "$DEVSRC/rust/.cargo/env"

[[ ! -r '/home/paradox/.dev/.opam/opam-init/init.zsh' ]] || source '/home/paradox/.dev/.opam/opam-init/init.zsh' >/dev/null 2>/dev/null

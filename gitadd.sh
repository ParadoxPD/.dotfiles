rm -rf .git
git init
git submodule add git@github.com:ParadoxPD/zsh-autocomplete.git zsh/zsh-autocomplete
git submodule add git@github.com:ParadoxPD/zsh-syntax-highlighting.git zsh/zsh-syntax-highlighting
git submodule add git@github.com:ParadoxPD/neovim-config.git config/nvim
git add .

#!/usr/bin/env bash

rm -rf ~/.dev/neovim

cd ~/Downloads/neovim || exit
make distclean
rm -rf build .deps

git fetch --all
git pull origin master

make CMAKE_BUILD_TYPE=RelWithDebInfo CMAKE_INSTALL_PREFIX=/home/paradox/.dev/neovim
make install

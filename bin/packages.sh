#!/bin/bash

set -euo pipefail

script_dir="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"
dotfiles="$(dirname "$script_dir")"

if command -v brew &>/dev/null; then
  echo >&2 "* Installing/upgrade brew bundle from ${dotfiles}/Brewfile"
  brew bundle upgrade --file "${dotfiles}/Brewfile"
else
  echo >&2 "!! Skipping install of brew bundle as brew is not in path"
fi

if command -v vim &>/dev/null; then
  if [ ! -d ~/.config/nvim/bundle/Vundle.vim ]; then
    echo >&2 "* Installing vundle"
    mkdir -p ~/.config/nvim/bundle/
    git clone https://github.com/VundleVim/Vundle.vim.git ~/.config/nvim/bundle/Vundle.vim
  fi
  echo >&2 "* Updating/installing vim plugins"
  vim +PluginInstall! +qall! &>/dev/null
else
  echo >&2 "!! Skipping install of vim plugins as vim is not in path"
fi

if command -v uv &>/dev/null; then
  echo >&2 "* Installing uv tools"
   uv tool install git+https://github.com/gbagnoli/GPicSync@cli
   uv tool install git+https://github.com/gbagnoli/photo_process
else
  echo >&2 "!! Skipping install of uv tools uv is not in path"
fi

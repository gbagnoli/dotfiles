#!/bin/bash

set -euo pipefail

dotfiles="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"

"${dotfiles}"/download.sh
declare -A filemap
filemap["${HOME}/.config/flake8"]="${dotfiles}/flake8"
filemap["${HOME}/.config/liquidpromptrc"]="${dotfiles}/liquidpromptrc"
filemap["${HOME}/.config/nvim/init.vim"]="${dotfiles}/vim/vimrc"
filemap["${HOME}/.vim"]="${HOME}/.config/nvim"
filemap["${HOME}/.vimrc"]="${dotfiles}/vim/vimrc"
filemap["${HOME}/.ssh/authorized_keys"]="${dotfiles}/ssh/authorized_keys"

declare -a simple=(inputrc gitconfig bashrc gitignore_global tmux.conf profile distrobox.ini)
for conf in "${simple[@]}"; do
  filemap["${HOME}/.${conf}"]="${dotfiles}/${conf}"
done

for dst in "${!filemap[@]}"; do
  src="${filemap[$dst]}"
  test -d "$(dirname "$dst")"
  [ ! -L "$dst" ] && rm -fv "$dst"
  ln -sfv "${src}" "${dst}"
done

if command -v brew &>/dev/null; then
  brew bundle upgrade --file "${dotfiles}/Brewfile"
  # install vim plugins
  vim +PluginInstall! +qall!
fi

if command -v uv &>/dev/null; then
   uv tool install git+https://github.com/gbagnoli/GPicSync@cli
   uv tool install git+https://github.com/gbagnoli/photo_process
fi

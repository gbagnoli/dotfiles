#!/bin/bash

set -euo pipefail

dotfiles="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"

declare -A filemap
filemap["${HOME}/.config/flake8"]="${dotfiles}/flake8"
filemap["${HOME}/.config/liquidpromptrc"]="${dotfiles}/liquidpromptrc"
filemap["${HOME}/.config/nvim/init.vim"]="${dotfiles}/vim/vimrc"
filemap["${HOME}/.vim"]="${HOME}/.config/nvim"
filemap["${HOME}/.vimrc"]="${dotfiles}/vim/vimrc"

declare -a simple=(inputrc gitconfig bashrc gitignore_global tmux.conf profile)
for conf in "${simple[@]}"; do
  filemap["${HOME}/.${conf}"]="${dotfiles}/${conf}"
done

for dst in "${!filemap[@]}"; do
  src="${filemap[$dst]}"
  test -f "$src"
  test -d "$(dirname "$dst")"
  ln -sfv "${src}" "${dst}"

done

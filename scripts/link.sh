#!/bin/bash

set -euo pipefail

script_dir="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"
dotfiles="$(dirname "$script_dir")"
binsource="${dotfiles}/bin"
bindir="${HOME}/.local/bin"

declare -A filemap
filemap["${HOME}/.config/flake8"]="${dotfiles}/flake8"
filemap["${HOME}/.config/liquidpromptrc"]="${dotfiles}/liquidpromptrc"
filemap["${HOME}/.config/nvim/init.vim"]="${dotfiles}/vim/vimrc"
filemap["${HOME}/.config/tzbuddy/tzbuddy.toml"]="${dotfiles}/tzbuddy.toml"
filemap["${HOME}/.ssh/authorized_keys"]="${dotfiles}/ssh/authorized_keys"
filemap["${HOME}/.vim"]="${HOME}/.config/nvim"
filemap["${HOME}/.vimrc"]="${dotfiles}/vim/vimrc"
filemap["${HOME}/.config/yamllint/config"]="${dotfiles}/yamllint"

declare -a simple=(inputrc gitconfig bashrc gitignore_global tmux.conf profile distrobox.ini)
for conf in "${simple[@]}"; do
  filemap["${HOME}/.${conf}"]="${dotfiles}/${conf}"
done

mkdir -p "$bindir"
for binary in "$binsource"/*; do
  filemap["${bindir}/$(basename "${binary}")"]="$binary"
done

for dst in "${!filemap[@]}"; do
  src="${filemap[$dst]}"
  test -d "$(dirname "$dst")" || mkdir -pv "$(dirname "$dst")"
  [ ! -L "$dst" ] && echo -n >&2 "* removing $dst" && rm -fv "$dst"
  echo -n >&2 "* " && ln -sfv "${src}" "${dst}"
done

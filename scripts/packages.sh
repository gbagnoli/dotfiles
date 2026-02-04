#!/bin/bash

set -euo pipefail

script_dir="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"
dotfiles="$(dirname "$script_dir")"
bindir="${HOME}/.local/bin"

brew_profile="$1"
install_vim_plugins="$2"

create_wrapper() {
  cat >"${bindir}/$1"
  chmod +x "${bindir}/$1"
}

if command -v brew &>/dev/null; then
  echo >&2 "* Installing/upgrade brew bundle from ${dotfiles}/brew/Brewfile.${brew_profile}"
  brew bundle upgrade --file "${dotfiles}/brew/Brewfile.${brew_profile}"
  if grep -q '"rust"' "${dotfiles}/brew/Brewfile.${brew_profile}" && command -v rustup &>/dev/null; then
    echo >&2 "* Linking brew rust toolchain in rustup as 'system'"
    rustup toolchain link system  "$(brew --prefix rust)"
  fi
else
  echo >&2 "!! Skipping install of brew bundle as brew is not in path"
fi

if command -v vim &>/dev/null && [ "$install_vim_plugins" -eq "1" ]; then
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
else
  echo >&2 "!! Skipping install of uv tools uv is not in path"
fi


if command -v flatpak &>/dev/null; then
  # xargs flatpak install --system -y < "$dotfiles/flatpak.txt"
  # use 'EOL' to avoid variable expansion
  cat <<'EOL' | create_wrapper keepassxc-cli
#!/bin/bash
exec flatpak run --command='keepassxc-cli' org.keepassxc.KeePassXC "$@"
EOL
fi

#!/bin/bash
# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
# shellcheck disable=SC2039
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
# shellcheck disable=SC2039
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

# shellcheck disable=SC2154
if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    if [ -r ~/.dircolors ];then
      eval "$(dircolors -b ~/.dircolors)"
    else
      eval "$(dircolors -b)"
    fi
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
  # shellcheck source=/dev/null
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    source /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    # shellcheck source=/dev/null
    source /etc/bash_completion
  fi
fi

export CLICOLOR=1
export PATH="$HOME/.local/bin:$PATH"
if [ -d /opt/android/platform-tools/ ]; then
  export PATH="$PATH:/opt/android/platform-tools"
fi

BREW_D="/home/linuxbrew/.linuxbrew"
if [ -d "${BREW_D}" ]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

  # setup bash completions
  HOMEBREW_PREFIX="$(brew --prefix)"
  if [[ -r "${HOMEBREW_PREFIX}/etc/profile.d/bash_completion.sh" ]] && ! shopt -oq posix; then
    # shellcheck source=/dev/null
    source "${HOMEBREW_PREFIX}/etc/profile.d/bash_completion.sh"
  else
    for COMPLETION in "${HOMEBREW_PREFIX}/etc/bash_completion.d/"*
    do
      # shellcheck source=/dev/null
      [[ -r "${COMPLETION}" ]] && source "${COMPLETION}"
    done
  fi


  # setup auto-bundle-dump utility
  brew_bundle_dump() {
    cd ~/workspace/dotfiles/ || return 1
    if [ -z "$(git status --porcelain)" ]; then
      git pull --rebase || return 1
      echo >&2 "* Updating Brewfile at ~/workspace/dotfiles/Brewfile"
      echo >&2 "  brew bundle dump --force --file ~/workspace/dotfiles/Brewfile"
      brew bundle dump --force --file ~/workspace/dotfiles/Brewfile || return 1
      git diff --exit-code Brewfile && echo >&2 "* Brewfile not updated, nothing else to do" && return 0
      echo >&2 "* Committing Brewfile to git"
      git add Brewfile && \
         git commit -m 'Auto update Brewfile'\
         && git push
      return $?
    else
      echo >&2 "** !!! git directory is not clean"
      return 1
    fi
  }

  brew_update() {
     echo >&2 "* brew update"
     brew update
     echo >&2 "* brew upgrade"
     brew upgrade
     echo >&2 "* brew cleanup"
     brew cleanup
     if [ -f ~/workspace/dotfiles/Brewfile ]; then
       brew_bundle_dump || echo >&2 "** !!! Failed to dump brew bundle"
     else
      echo >&2 '** !!! cannot find brew file at ~/workspace/dotfiles/Brewfile'
     fi

     # update also uv tools
     if command -v uv &>/dev/null; then
       echo >&2 "* uv tool upgrade --all"
       uv tool upgrade --all
     fi
  }
fi

# GO
export GO15VENDOREXPERIMENT=1
export GOPATH=$HOME/workspace/go
export PATH=$PATH:$GOPATH/bin

create_coord() {
    [ $# -eq 0 ] && echo 'Usage: create_coord <coordinates>' && return 1
    [ -f coord.txt ] && echo "FAIL: coord.txt already exists" && return 1
    echo "$@" > coord.txt
}

# shellcheck disable=SC2039
if command -v rbenv &>/dev/null; then
  eval "$(rbenv init -)"
fi

if command -v zoxide &>/dev/null; then
  eval "$(zoxide init bash --cmd j)"
  # shellcheck source=/dev/null
  [ -f /etc/bash_completion.d/zoxide.bash ] && source /etc/bash_completion.d/zoxide.bash
fi

if command -v fzf &>/dev/null; then
  fzf --help | grep -q -- --bash && eval "$(fzf --bash)"
fi

# shellcheck disable=SC1091
# shellcheck disable=SC2039
# Only load liquidprompt in interactive shells, not from a script or from scp
[[ $- = *i* ]] && [ -f "${BREW_D}"/share/liquidprompt ] && source "${BREW_D}"/share/liquidprompt

if [ -f "${BREW_D}/opt/autoenv/activate.sh" ]; then
  # shellcheck source=/dev/null
  source "${BREW_D}/opt/autoenv/activate.sh"
fi

if brew --prefix rustup &>/dev/null; then
  _pfx="$(brew --prefix rustup)/bin"
  export PATH="${_pfx}:${PATH}"
fi

if [ -d "$HOME/.cargo/bin" ]; then
  export PATH="$PATH:$HOME/.cargo/bin"
  # shellcheck source=/dev/null
  source "$HOME/.cargo/env"
fi

if [ -f "$HOME/.bashrc.local" ]; then
  # shellcheck source=/dev/null
. "$HOME/.bashrc.local"
fi

alias tmux="tmux -2"
alias tz="tzbuddy -s 6"

if command -v lsb_release &>/dev/null && command lsb_release -d 2>&1 | grep -q Ubuntu; then
apt_update() {
  yes | (
    sudo apt update && \
    sudo apt full-upgrade && \
    sudo apt autoremove && \
    sudo apt autoclean
  )
  if command -v flatpak >/dev/null; then
    echo "Updating flatpak"
    sudo flatpak update --noninteractive -y
  fi

  if command -v brew >/dev/null; then
    brew_update
  fi
}
fi

download_m3u() {
  local url
  local output
  [ $# -lt 1 ] && echo >&2 "usage: $0 <url> [output]" && return 1
  url="$1"
  if [ $# -ge 2 ]; then
    output="$2"
    shift
  else
    output="${1/.m3u8/.mp4}"
  fi
  shift;
  echo ffmpeg -i "$url" -bsf:a aac_adtstoasc -vcodec copy -c copy "${output}" "$@"
  ffmpeg -i "$url" -bsf:a aac_adtstoasc -vcodec copy -c copy "${output}" "$@"
}

exiftool_map_url() {
  exiftool -config ~/.local/src/exiftool_GPS2MapUrl.config -GoogleMapsUrl "$@"
}

dd_to_iso() {
  local output
  local device
  local blocksize
  local volumesize
  [ $# -lt 1 ] && echo >&2 "usage: $0 <output> [device]" && return 1
  output="$1"
  if [ $# -ge 2 ]; then
    device="$2"
    shift
  else
    device="/dev/cdrom"
  fi
  set -o pipefail
  isoinfo="$(isoinfo -d -i "$device" | grep -i -E 'block size|volume size')"
  local err=$?
  if [ $err -ne 0 ]; then
    echo >&2 "Could not run isoinfo"
    return $err
  fi
  blocksize="$(echo "$isoinfo" | grep -i 'block' | sed -e 's/.*: //')"
  volumesize="$(echo "$isoinfo" | grep -i 'volume' | sed -e 's/.*: //')"
  echo "Device: $device, block size: $blocksize, volume size: $volumesize"
  dd if="$device" bs="$blocksize" count="$volumesize" status=progress | xz -T 0 -c -z - > "$output"
}
[ -x /usr/local/bin/ollama ] && alias ollama="sudo ollama"

wake_ubik() {
  bin=""
  if command -v ethwewake &>/dev/null; then
    bin="etherwake"
  fi
  if command -v ether-wake &>/dev/null; then
    bin="ether-wake"
  fi
  [ -z "$bin" ] && echo >&2 "cannot find etherwake or ether-wake" && return 1
  MAC="2c:f0:5d:0e:a6:28"
  echo "running: $bin $MAC"
  sudo "$bin" "$MAC"
}

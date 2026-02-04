#!/bin/bash
set -euo pipefail

dotfiles="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"
script_dir="${dotfiles}/scripts"
brew_profiles_dir="${dotfiles}/brew"
brew_profiles=()
brew_profile=""

shell_join() {
  local arg
  printf "%s" "$1"
  shift
  for arg in "$@"
  do
    printf " %s" "${arg// /\ }"
  done
}

get_brew_profile_from_path() {
  local path
  path="$1"
  basename "${path/Brewfile.//}"
}

# try to see if we installed a profile
if [ -L "${HOME}/.config/Brewfile" ]; then
  brewfile="$(readlink -f "${HOME}/.config/Brewfile")"
  brew_profile="$(get_brew_profile_from_path "$brewfile")"
fi

# list available profiles
for brewfile in "${brew_profiles_dir}"/Brewfile*; do
  brew_profiles+=("$(get_brew_profile_from_path "${brewfile}")")
done

usage() {
  exit_code=0
  [ $# -ge 1 ] && exit_code="$1" && shift
  [ $# -ge 1 ] && echo -e >&2 "$@" && echo >&2
  echo -e >&2 "Usage: $(basename "$0") [-h] -b <brew_profile>"
  echo -e >&2
  echo -e >&2 "Options"
  echo -e >&2 "  -h: print this help"
  echo -e >&2 "  -b: brew profile to use. available profiles: $(shell_join "${brew_profiles[@]}")"
  if [ -n "$brew_profile" ]; then
    echo -e >&2 "      current brew profile discovered: $brew_profile"
  fi
  exit "$exit_code"
}

while getopts "b:h" opt; do
  case $opt in
    b)
      brew_profile="$OPTARG"
      if [[ ! " ${brew_profiles[*]} " =~ [[:space:]]${brew_profile}[[:space:]] ]]; then
          usage 1 "ERROR: Could not find profile ${brew_profile}"
      fi
      ;;
    h) usage 0;;
    \?) echo "Invalid option -$OPTARG" >&2; exit 1 ;;
  esac
done

[ -z "${brew_profile}" ] && usage 1 "Missing brew profile"

"${script_dir}"/download.sh
"${script_dir}"/link.sh "$brew_profile"
"${script_dir}"/packages.sh "$brew_profile"

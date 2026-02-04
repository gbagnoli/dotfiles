#!/bin/bash
set -euo pipefail

dotfiles="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"
script_dir="${dotfiles}/scripts"
brew_profiles_dir="${dotfiles}/brew"
brew_profiles=()
brew_profile="minimal"

for brewfile in "${brew_profiles_dir}"/Brewfile*; do
  brew_profiles+=("$(basename "${brewfile/Brewfile.//}")")
done

shell_join() {
  local arg
  printf "%s" "$1"
  shift
  for arg in "$@"
  do
    printf " %s" "${arg// /\ }"
  done
}


usage() {
  exit_code=0
  [ $# -ge 1 ] && exit_code="$1" && shift
  [ $# -ge 1 ] && echo -e >&2 "$@" && echo >&2
  echo -e >&2 "Usage: $(basename "$0") [-h] [-p profile]"
  echo -e >&2
  echo -e >&2 "Options"
  echo -e >&2 "  -h: print this help"
  echo -e >&2 "  -p: brew profile to use. available profiles: $(shell_join "${brew_profiles[@]}")"
  exit "$exit_code"
}

while getopts "p:h" opt; do
  case $opt in
    p)
      brew_profile="$OPTARG"
      if [[ ! " ${brew_profiles[*]} " =~ [[:space:]]${brew_profile}[[:space:]] ]]; then
          usage 1 "ERROR: Could not find profile ${brew_profile}"
      fi
      ;;
    h) usage 0;;
    \?) echo "Invalid option -$OPTARG" >&2; exit 1 ;;
  esac
done

"${script_dir}"/download.sh
"${script_dir}"/link.sh
"${script_dir}"/packages.sh "$brew_profile"

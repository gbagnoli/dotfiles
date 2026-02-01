#!/bin/bash
set -euo pipefail

dotfiles="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"
script_dir="${dotfiles}/scripts"

"${script_dir}"/download.sh
"${script_dir}"/link.sh
"${script_dir}"/packages.sh

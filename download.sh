#!/bin/bash

set -euo pipefail

share=${HOME}/.local/share
mkdir -p "$share/liquidprompt"

curl -o "$share/liquidprompt/nerd-font.conf" https://raw.githubusercontent.com/liquidprompt/liquidprompt/refs/heads/master/contrib/presets/nerd-font.conf
curl -o "$share/liquidprompt/256-colors-light.conf" https://raw.githubusercontent.com/liquidprompt/liquidprompt/refs/heads/master/contrib/presets/colors/256-colors-light.conf

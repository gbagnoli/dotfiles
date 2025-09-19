#!/bin/bash

set -euo pipefail

share=${HOME}/.local/share
mkdir -p "$share/liquidprompt"

echo >&2 "* Downloading liquidprompt nerd font config"
curl -s -o "$share/liquidprompt/nerd-font.conf" https://raw.githubusercontent.com/liquidprompt/liquidprompt/refs/heads/master/contrib/presets/nerd-font.conf
echo >&2 "* Downloading liquidprompt colors config"
curl -s -o "$share/liquidprompt/256-colors-light.conf" https://raw.githubusercontent.com/liquidprompt/liquidprompt/refs/heads/master/contrib/presets/colors/256-colors-light.conf

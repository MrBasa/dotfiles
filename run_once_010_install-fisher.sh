#!/bin/bash
# Installs Fisher
set -eu
echo "Running: " $(basename $0)

if ! fish -c "functions -q fisher"; then
  echo "Installing Fisher..."
  fish -c "curl -sL https://git.io/fisher | source && fisher install jorgebucaran/fisher"
fi

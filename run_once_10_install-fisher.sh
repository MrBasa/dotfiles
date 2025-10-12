#!/bin/bash
# Installs Fisher and the initial set of plugins from fish_plugins.
set -eu

if ! fish -c "functions -q fisher"; then
  echo "Installing Fisher..."
  fish -c "curl -sL https://git.io/fisher | source && fisher install jorgebucaran/fisher"
fi

echo "Installing initial set of Fisher plugins..."
fish -c "fisher update"

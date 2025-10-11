#!/bin/bash
#
# This script runs 'fisher update' every time 'chezmoi apply' is executed,
# ensuring your Fish shell plugins are always in sync with your 'fish_plugins' file.

set -eu

# Check if 'fish' and 'fisher' commands are available
if command -v fish &> /dev/null && fish -c "functions -q fisher"; then
  echo "Updating Fisher plugins..."
  fish -c "fisher update"
fi

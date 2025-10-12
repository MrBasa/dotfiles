#!/bin/bash
# Runs 'fisher update' every time 'chezmoi apply' is executed for ongoing maintenance.
set -eu

if command -v fish &> /dev/null && fish -c "functions -q fisher"; then
  echo "Updating Fisher plugins..."
  fish -c "fisher update"
fi

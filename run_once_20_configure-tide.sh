#!/bin/bash
# Applies a one-time, automated configuration to the Tide prompt.
set -eu

if fish -c "functions -q tide"; then
  echo "Applying automatic Tide configuration..."
  fish -c "tide configure --auto --style=Classic --prompt_colors='True color' --classic_prompt_color=Dark --show_time='24-hour format' --classic_prompt_separators=Angled --powerline_prompt_heads=Slanted --powerline_prompt_tails=Flat --powerline_prompt_style='Two lines, character' --prompt_connection=Dotted --powerline_right_prompt_frame=No --prompt_connection_andor_frame_color=Darkest --prompt_spacing=Sparse --icons='Many icons' --transient=Yes"
else
  echo "WARNING: 'tide' command not found, skipping configuration." >&2
fi

#!/usr/bin/env bash

get_text() {
  /home/gabriel/.config/waybar/custom_modules/media/media_control.sh text
}

export -f get_text

zscroll -l 25 \
  --delay 0.25 \
  --scroll-padding "   |   " \
  --match-command "/home/gabriel/.config/waybar/custom_modules/media/media_control.sh status" \
  --match-text "Playing" "--scroll 1" \
  --match-text "Paused" "--scroll 0" \
  --update-check true \
  "bash -c get_text" 2>/dev/null

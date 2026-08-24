#!/usr/bin/env bash

get_metadata() {
  status=$(playerctl --player=playerctld --ignore-player=kdeconnect status 2>/dev/null)
  if [ -z "$status" ]; then
    echo ""
    return
  fi

  player=$(playerctl --ignore-player=kdeconnect metadata --format '{{playerName}}' 2>/dev/null)
  case "$player" in
    *spotify*) icon="" ;;
    *firefox*|*zen*) icon="󰈹" ;;
    *chromium*|*chrome*) icon="" ;;
    *mpv*) icon="󰐹" ;;
    *vlc*) icon="󰕼" ;;
    *) icon="" ;;
  esac

  meta=$(playerctl --player=playerctld --ignore-player=kdeconnect metadata --format '{{title}} - {{artist}}' 2>/dev/null)
  if [ -n "$meta" ]; then
    echo "$icon $meta"
  else
    echo ""
  fi
}

export -f get_metadata

zscroll -l 25 \
  --delay 0.25 \
  --scroll-padding "   |   " \
  --match-command "playerctl --player=playerctld --ignore-player=kdeconnect status 2>/dev/null" \
  --match-text "Playing" "--scroll 1" \
  --match-text "Paused" "--scroll 0" \
  --update-check true \
  "bash -c get_metadata" 2>/dev/null

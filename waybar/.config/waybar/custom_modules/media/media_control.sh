#!/usr/bin/env bash

STATE_FILE="/tmp/waybar_selected_player"

get_valid_players() {
  playerctl -l 2>/dev/null | grep -v 'kdeconnect' | grep -v 'playerctld'
}

get_active_player() {
  local players=($(get_valid_players))
  if [ ${#players[@]} -eq 0 ]; then
    echo ""
    return
  fi

  local selected=""
  if [ -f "$STATE_FILE" ]; then
    selected=$(cat "$STATE_FILE" 2>/dev/null)
  fi

  for p in "${players[@]}"; do
    if [ "$p" = "$selected" ]; then
      echo "$selected"
      return
    fi
  done

  # If selected is not in valid list, check if any is playing
  for p in "${players[@]}"; do
    local st
    st=$(playerctl -p "$p" status 2>/dev/null)
    if [ "$st" = "Playing" ]; then
      echo "$p" > "$STATE_FILE"
      echo "$p"
      return
    fi
  done

  echo "${players[0]}" > "$STATE_FILE"
  echo "${players[0]}"
}

get_player_icon() {
  local p="$1"
  case "$p" in
    *spotify*) echo "" ;;
    *firefox*|*zen*) echo "󰈹" ;;
    *chromium*|*chrome*) echo "" ;;
    *mpv*) echo "󰐹" ;;
    *vlc*) echo "󰕼" ;;
    *) echo "" ;;
  esac
}

case "$1" in
  switch)
    players=($(get_valid_players))
    if [ ${#players[@]} -le 1 ]; then
      exit 0
    fi
    cur=$(get_active_player)
    idx=0
    for i in "${!players[@]}"; do
      if [ "${players[$i]}" = "$cur" ]; then
        idx=$i
        break
      fi
    done
    if [ "$2" = "prev" ]; then
      next_idx=$(( (idx - 1 + ${#players[@]}) % ${#players[@]} ))
    else
      next_idx=$(( (idx + 1) % ${#players[@]} ))
    fi
    echo "${players[$next_idx]}" > "$STATE_FILE"
    pkill -RTMIN+9 waybar 2>/dev/null || true
    ;;

  play-pause)
    p=$(get_active_player)
    if [ -n "$p" ]; then
      playerctl -p "$p" play-pause 2>/dev/null
    fi
    pkill -RTMIN+9 waybar 2>/dev/null || true
    ;;

  next)
    p=$(get_active_player)
    if [ -n "$p" ]; then
      playerctl -p "$p" next 2>/dev/null
    fi
    pkill -RTMIN+9 waybar 2>/dev/null || true
    ;;

  previous)
    p=$(get_active_player)
    if [ -n "$p" ]; then
      playerctl -p "$p" previous 2>/dev/null
    fi
    pkill -RTMIN+9 waybar 2>/dev/null || true
    ;;

  position)
    p=$(get_active_player)
    if [ -n "$p" ]; then
      playerctl -p "$p" position "$2" 2>/dev/null
    fi
    ;;

  status-icon)
    p=$(get_active_player)
    if [ -n "$p" ]; then
      st=$(playerctl -p "$p" status 2>/dev/null)
      if [ "$st" = "Playing" ]; then
        echo ""
      else
        echo ""
      fi
    else
      echo ""
    fi
    ;;

  text)
    p=$(get_active_player)
    if [ -z "$p" ]; then
      echo ""
      exit 0
    fi
    icon=$(get_player_icon "$p")
    meta=$(playerctl -p "$p" metadata --format '{{title}} - {{artist}}' 2>/dev/null)
    if [ -n "$meta" ]; then
      echo "$icon $meta"
    else
      echo "$icon $p"
    fi
    ;;

  status)
    p=$(get_active_player)
    if [ -n "$p" ]; then
      playerctl -p "$p" status 2>/dev/null
    else
      echo "Stopped"
    fi
    ;;
esac

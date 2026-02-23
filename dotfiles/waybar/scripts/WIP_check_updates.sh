#!/bin/bash

# Check if necessary commands exist
check_command() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "{\"text\": \"⚠\", \"tooltip\": \"Error: $1 is not installed\"}"
    exit 1
  fi
}

check_command checkupdates
check_command yay

# Get official repo updates
OFFICIAL=$(checkupdates 2>/dev/null | wc -l || echo 0)

# Get AUR updates
AUR=$(yay -Qua 2>/dev/null | wc -l || echo 0)

# Calculate total updates
TOTAL=$((OFFICIAL + AUR))

if [ "$TOTAL" -gt 0 ]; then
  OUTPUT=""

  if [ "$OFFICIAL" -gt 0 ]; then
    OUTPUT+="󰏗 $OFFICIAL"
  fi

  if [ "$AUR" -gt 0 ]; then
    [ -n "$OUTPUT" ] && OUTPUT+=" "
    OUTPUT+="󰚰 $AUR"
  fi

  # Format JSON for waybar
  echo "{\"text\": \"$OUTPUT\", \"tooltip\": \"Official: $OFFICIAL\\nAUR: $AUR\\nClick to update\"}"
else
  # Empty output for waybar
  echo "{\"text\": \"\", \"tooltip\": \"System is up to date\"}"
fi

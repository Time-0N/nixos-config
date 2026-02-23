#!/bin/bash

# Configuration
TERMINAL="kitty" # terminal emulator
NOTIFY_TIMEOUT=5000

# Notification icons
ICON_UPDATE="󰚰"
ICON_SUCCESS="󰄬"
ICON_ERROR="󰅚"

# Helper function for notifications
notify() {
  local title="$1"
  local message="$2"
  local urgency="$3"
  local icon="$4"

  notify-send "$icon $title" "$message" -u "$urgency" -t $NOTIFY_TIMEOUT
}

# Check for official updates
OFFICIAL=$(checkupdates 2>/dev/null | wc -l || echo 0)

# Check for AUR updates
AUR=$(yay -Qua 2>/dev/null | wc -l || echo 0)

# Calculate total updates
TOTAL=$((OFFICIAL + AUR))

if [ "$TOTAL" -gt 0 ]; then
  notify "System Update" "Found updates:\n• Official: $OFFICIAL\n• AUR: $AUR\nStarting update..." "normal" "$ICON_UPDATE"

  # Create a temporary script to run in terminal
  UPDATE_SCRIPT=$(mktemp)
  cat >"$UPDATE_SCRIPT" <<'EOF'
#!/bin/bash
echo "Starting system update..."
echo "========================"

# Update official packages
if sudo pacman -Syu --noconfirm; then
  echo ""
  echo "✓ Official packages updated successfully"
else
  echo ""
  echo "✗ Error updating official packages"
  read -p "Press Enter to exit..."
  exit 1
fi

echo ""
echo "Updating AUR packages..."
echo "========================"

# Update AUR packages
if yay -Sua --noconfirm; then
  echo ""
  echo "✓ AUR packages updated successfully"
else
  echo ""
  echo "✗ Error updating AUR packages"
  read -p "Press Enter to exit..."
  exit 1
fi

echo ""
echo "================================"
echo "All updates completed successfully!"
echo "================================"
read -p "Press Enter to exit..."
exit 0
EOF

  chmod +x "$UPDATE_SCRIPT"

  # Launch terminal with the update script
  $TERMINAL -e bash -c "$UPDATE_SCRIPT; UPDATE_EXIT=\$?; rm -f $UPDATE_SCRIPT; exit \$UPDATE_EXIT" &

  # Wait for terminal to finish
  wait $!
  UPDATE_EXIT_CODE=$?

  if [ $UPDATE_EXIT_CODE -eq 0 ]; then
    notify "Update Complete" "System has been successfully updated\n• Official: $OFFICIAL\n• AUR: $AUR" "normal" "$ICON_SUCCESS"

    # Trigger waybar to refresh the update count
    pkill -RTMIN+1 waybar
  else
    notify "Update Error" "Update process was interrupted or failed\nCheck terminal for details" "critical" "$ICON_ERROR"
  fi
else
  notify "System Update" "Your system is up to date" "normal" "$ICON_SUCCESS"
fi

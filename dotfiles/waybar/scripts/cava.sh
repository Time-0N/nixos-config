#!/usr/bin/env bash

bar="▁▂▃▄▅▆▇█"
dict="s/;//g"
bar_length=${#bar}
for ((i = 0; i < bar_length; i++)); do
  dict+=";s/$i/${bar:$i:1}/g"
done

# Lock file directory
LOCK_DIR="/tmp/cava_waybar_locks"
mkdir -p "$LOCK_DIR"

# Count connected monitors (using hyprctl!)
monitor_count=$(hyprctl monitors -j 2>/dev/null | jq length || swaymsg -t get_outputs 2>/dev/null | jq length || wlr-randr 2>/dev/null | grep -c "^[^ ]" || echo 2)

# Check if any lock files exist (meaning instances are already running)
current_locks=$(find "$LOCK_DIR" -name "lock_*" 2>/dev/null | wc -l)

if [ "$current_locks" -gt 0 ]; then
  # Kill all existing cava instances for waybar
  pkill -f "cava.*cava_waybar"

  # Clean up all lock files
  rm -f "$LOCK_DIR"/lock_*

  # Wait a moment for processes to terminate
  sleep 0.2
fi

# Count lock files again to ensure we start the right number
current_locks=$(find "$LOCK_DIR" -name "lock_*" 2>/dev/null | wc -l)

# Exit if we already have enough instances (shouldn't happen after cleanup, but safe)
if [ "$current_locks" -ge "$monitor_count" ]; then
  exit 0
fi

# Create unique lock file for this instance
LOCK_FILE="$LOCK_DIR/lock_$$"
touch "$LOCK_FILE"
trap 'rm -f "$config_file" "$LOCK_FILE"' EXIT

# Per-instance temp config
config_file="$(mktemp -t cava_waybar_XXXX.conf)"

cat >"$config_file" <<EOF
[general]
framerate = 60
bars = 14
[input]
method = pipewire
source = auto
[output]
method = raw
raw_target = /dev/stdout
data_format = ascii
ascii_max_range = 7
EOF

# Keep the process alive. Incase Cava exits briefly, retry
while :; do
  cava -p "$config_file" | sed -u "$dict"
  sleep 0.5
done

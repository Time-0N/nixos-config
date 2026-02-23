#!/bin/bash
# arg $1 = widget name (same as defwindow)
WIDGET=$1

# which monitor has focus?
MON=$(hyprctl monitors -j | jq -r '.[] | select(.focused==true) | .model')

# close any old copies of this widget (optional: close-all)
eww close "$WIDGET" 2>/dev/null

# open on the focused monitor
eww open --screen "$MON" "$WIDGET"

# ---------- auto-close bit (same as before) ----------
while sleep 0.2; do
  read X Y <<<$(hyprctl cursorpos -j | jq -r '.x, .y')
  read x y w h <<<$(hyprctl clients -j |
    jq -r --arg w "$WIDGET" '
          .[] | select(.class==$w or .title==$w) |
          "\(.at[0]) \(.at[1]) \(.size[0]) \(.size[1])" 2>/dev/null')
  # if widget closed externally, quit loop
  [[ -z $x ]] && break
  # inside check
  ((X >= x && X <= x + w && Y >= y && Y + h >= Y)) && continue
  # mouse button pressed? wait
  grep -q true <<<$(hyprctl cursorpos -j | jq -r .pressed) && continue
  break
done

eww close "$WIDGET"

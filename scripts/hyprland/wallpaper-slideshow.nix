{ pkgs }:

pkgs.writeShellScriptBin "wallpaper-slideshow" ''
  WALLPAPER_DIR="$HOME/pictures/wallpaper/slideshow"
  INTERVAL=600
  LOCKFILE="/tmp/wallpaper-slideshow.lock"

  if [ -f "$LOCKFILE" ]; then
    if ${pkgs.procps}/bin/ps -p "$(cat "$LOCKFILE")" >/dev/null 2>&1; then
      exit 0
    fi
  fi

  echo $$ > "$LOCKFILE"
  trap "rm -f $LOCKFILE" EXIT
  sleep 3

  WALLPAPERS=()
  while IFS= read -r -d "" file; do
    WALLPAPERS+=("$file")
  done < <(find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) -print0)

  [ ''${#WALLPAPERS[@]} -eq 0 ] && exit 1

  get_random_wallpaper() {
    printf "%s\n" "''${WALLPAPERS[@]}" | ${pkgs.coreutils}/bin/shuf -n 1
  }

  set_wallpaper() {
    ${pkgs.swww}/bin/swww img "$1" \
      --transition-type "$2" \
      --transition-fps 120 \
      --transition-duration 1 \
      --resize crop \
      --filter CatmullRom
  }

  CURRENT=$(get_random_wallpaper)
  set_wallpaper "$CURRENT" "simple"

  while true; do
    sleep "$INTERVAL"
    NEXT=$(get_random_wallpaper)
    while [ "$NEXT" = "$CURRENT" ] && [ ''${#WALLPAPERS[@]} -gt 1 ]; do
      NEXT=$(get_random_wallpaper)
    done
    set_wallpaper "$NEXT" "wipe"
    CURRENT="$NEXT"
  done
''

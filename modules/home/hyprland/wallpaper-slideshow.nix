{ pkgs, ... }:
let
  wallpaper-slideshow = pkgs.writeShellScriptBin "wallpaper-slideshow" ''
    WALLPAPER_DIR="$HOME/pictures/wallpaper/slideshow"
    INTERVAL=600

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
      ${pkgs.swww}/bin/awww img "$1" \
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
  '';
in
{
  home.packages = [
    pkgs.awww
    wallpaper-slideshow
  ];

  systemd.user.services.wallpaper-slideshow = {
    Unit = {
      Description = "Wallpaper slideshow";
      After = "graphical-session.target";
      PartOf = "graphical-session.target";
    };
    Service = {
      ExecStart = "${wallpaper-slideshow}/bin/wallpaper-slideshow";
      Restart = "always";
      RestartSec = 3;
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };
}

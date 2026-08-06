{
  inputs,
  pkgs,
  ...
}:
let
  cursor-theme = import ../../lib/cursor.nix { inherit pkgs; };
in
{
  imports = [ inputs.qylock.nixosModules.default ];

  services.displayManager = {
    defaultSession = "hyprland-uwsm";

    sddm = {
      enable = true;
      wayland.enable = true;

      settings = {
        General = {
          GreeterEnvironment = builtins.concatStringsSep "," [
            "QT_MEDIA_BACKEND=ffmpeg"
            "XCURSOR_PATH=/run/current-system/sw/share/icons"
          ];
          InputMethod = "";
        };

        Theme = {
          CursorTheme = "MacOSX-Cursor";
          CursorSize = 24;
        };
      };
    };
  };

  environment.systemPackages = [ cursor-theme ];

  xdg.icons.fallbackCursorThemes = [ "MacOSX-Cursor" ];

  programs.qylock = {
    enable = true;
    theme = "pixel-hollowknight";

    # Puts `qylock-lock` on PATH with QS_THEME defaulted to the theme above.
    # Driven via the `lockscreen` wrapper in modules/home/hyprland/lockscreen.nix.
    quickshell.enable = true;
  };
}

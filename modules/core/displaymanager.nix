{
  config,
  inputs,
  lib,
  pkgs,
  vars,
  ...
}:
let
  cursor-theme = import ../../lib/cursor.nix { inherit pkgs; };
  cursorName = "MacOSX-Cursor";
  cursorSize = 24;

  xkb = config.services.xserver.xkb;

  westonIni = (pkgs.formats.ini { }).generate "weston.ini" {
    core = {
      shell = "kiosk";
      # Keep this at 0. Only desktop-shell acts on weston's idle signal, and
      # there it blanks the greeter's outputs without bringing them back.
      # Unset falls back to weston's built-in 300 s.
      idle-time = 0;
      require-input = false;
    };
    shell = {
      background-color = "0xff000000";
    };
    # Empty path stops weston from launching weston-keyboard over the greeter.
    "input-method" = {
      path = "";
    };
    libinput = {
      enable-tap = config.services.libinput.touchpad.tapping;
      left-handed = config.services.libinput.mouse.leftHanded;
    };
    keyboard = {
      keymap_model = xkb.model;
      keymap_layout = xkb.layout;
      keymap_variant = xkb.variant;
      keymap_options = xkb.options;
    };
  };
in
{
  imports = [ inputs.qylock.nixosModules.default ];

  services.displayManager = {
    defaultSession = "hyprland-uwsm";
    sddm = {
      enable = true;
      wayland = {
        enable = true;
        # Pin this - plasma6.nix flips it to kwin with mkDefault, and the
        # compositorCommand default follows whatever is selected here.
        compositor = "weston";
        compositorCommand = "${lib.getExe pkgs.weston} -c ${westonIni}";
      };
      settings = {
        General = {
          GreeterEnvironment = builtins.concatStringsSep "," [
            "QT_MEDIA_BACKEND=ffmpeg"
            "XCURSOR_PATH=/run/current-system/sw/share/icons"
          ];
          InputMethod = "";
        };
        Theme = {
          CursorTheme = cursorName;
          CursorSize = cursorSize;
        };
      };
    };
  };

  environment.systemPackages = [ cursor-theme ];
  xdg.icons.fallbackCursorThemes = [ cursorName ];

  programs.qylock = {
    enable = true;
    theme = vars.qylockTheme;
    # Puts `qylock-lock` on PATH with QS_THEME defaulted to the theme above.
    # Driven via the `lockscreen` wrapper in modules/home/hyprland/lockscreen.nix.
    quickshell.enable = true;
  };
}

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

  # Blank the greeter's displays after this long without input. Any key or
  # mouse movement wakes them back up. 0 would disable idling entirely.
  greeterIdleSeconds = 300;

  xkb = config.services.xserver.xkb;

  # nixpkgs' own weston.ini, plus the bits kiosk-shell can't do. The idle
  # signal is only acted on by desktop-shell, so we run that instead and
  # strip it back down until it behaves like a kiosk.
  westonIni = (pkgs.formats.ini { }).generate "weston.ini" {
    core = {
      shell = "desktop-shell.so";
      idle-time = greeterIdleSeconds;
      require-input = false;
    };
    shell = {
      panel-position = "none";
      background-color = "0xff000000";
      locking = false;
      animation = "fade";
      startup-animation = "none";
      cursor-theme = cursorName;
      cursor-size = cursorSize;
    };
    "input-method" = {
      path = "";
    };
    libinput = {
      enable-tap = config.services.libinput.mouse.tapping;
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

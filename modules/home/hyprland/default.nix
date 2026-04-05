{ lib, ... }:
{
  imports = [
    ./animations.nix
    ./autostart.nix
    ./decorations.nix
    ./environment.nix
    ./general.nix
    ./hypridle.nix
    ./hyprlock.nix
    ./input.nix
    ./keybinds.nix
    ./windowrules.nix
    ./wallpaper-slideshow.nix
    ./xwayland-primary.nix
  ];

  wayland.windowManager.hyprland = {
    enable = true;
    # Syslink for nwg-displays
    extraConfig = ''
      source = ~/.config/hypr/monitors.conf
      gesture = 3, horizontal, workspace
    '';
  };

  xdg.configFile."hypr/xdph.conf".text = ''
    screencopy {
      allow_token_by_default = true
    }
  '';

  home.activation.createMonitorsConf = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        MONITORS_CONF="$HOME/.config/hypr/monitors.conf"
        if [ ! -f "$MONITORS_CONF" ]; then
          mkdir -p "$(dirname "$MONITORS_CONF")"
          cat > "$MONITORS_CONF" << 'EOF'
    # Managed by nwg-displays — do not edit manually
    # Run nwg-displays to configure your monitors
    monitor = ,preferred,auto,1
    EOF
        fi
  '';
}

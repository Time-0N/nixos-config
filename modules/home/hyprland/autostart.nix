{ pkgs, ... }:
{
  home.packages = with pkgs; [
    xrandr
    jq
  ];

  wayland.windowManager.hyprland.settings.exec-once = [
    # Environment setup (should be first)
    "systemctl --user import-environment PATH"
    "systemctl --user import-environment HYPRLAND_INSTANCE_SIGNATURE WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
    "hash dbus-update-activation-environment 2>/dev/null &"
    "dbus-update-activation-environment --systemd &"

    # Services
    "systemctl --user start waybar"

    # UI Components
    "swww-daemon"
    "eww daemon"

    # Idle management
    "hypridle"

    # Cursor
    "hyprctl setcursor macOS 24"

    # Xwayland main monitor
    "sh -c 'xrandr --output $(hyprctl monitors -j | jq -r \".[0].name\") --primary'"
  ];
}

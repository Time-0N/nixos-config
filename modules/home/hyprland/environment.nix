{ ... }:
{
  wayland.windowManager.hyprland.settings = {
    env = [
      # Cursor
      "XCURSOR_THEME,macOS"
      "XCURSOR_SIZE,24"
      "HYPRCURSOR_SIZE,24"
      "QT_CURSOR_SIZE,24"

      # Session
      "XDG_SESSION_TYPE,wayland"
      "XDG_CURRENT_DESKTOP,Hyprland"
      "XDG_SESSION_DESKTOP,Hyprland"

      # Qt theming
      "QT_QPA_PLATFORMTHEME,qt6ct"
      "QT_STYLE_OVERRIDE,kvantum"
    ];
  };
}

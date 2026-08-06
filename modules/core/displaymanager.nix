{ inputs, ... }:
{
  imports = [ inputs.qylock.nixosModules.default ];

  services.displayManager = {
    # programs.hyprland.withUWSM = true registers "hyprland-uwsm.desktop"
    # under wayland-sessions; this is the session SDDM preselects.
    defaultSession = "hyprland-uwsm";

    sddm = {
      enable = true;

      # No X server anywhere in this config, so the greeter has to run on
      # Wayland (SDDM asserts on xserver.enable || wayland.enable).
      wayland.enable = true;

      settings.General = {
        # pixel-hollowknight draws an mp4 background via QtMultimedia. Pin the
        # FFmpeg backend so it can't fall back to GStreamer, whose plugins are
        # not on the greeter's search path.
        GreeterEnvironment = "QT_MEDIA_BACKEND=ffmpeg";

        # The theme brings its own input field; keep the virtual keyboard away.
        InputMethod = "";
      };
    };
  };

  programs.qylock = {
    enable = true;
    theme = "pixel-hollowknight";

    # Puts `qylock-lock` on PATH with QS_THEME defaulted to the theme above.
    # Driven via the `lockscreen` wrapper in modules/home/hyprland/lockscreen.nix.
    quickshell.enable = true;
  };
}

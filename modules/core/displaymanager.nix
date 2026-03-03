{
  pkgs,
  ...
}:
{
  # --- FONTS ---
  fonts.packages = with pkgs; [
    inter
  ];

  # --- SEAT ACCESS ---
  services.seatd.enable = true;
  users.users.greeter.extraGroups = [
    "seat"
    "video"
  ];

  # --- GREETD (replaces programs.regreet which hardcodes cage) ---
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        # Launch Hyprland as the greeter compositor for proper multi-monitor support
        command = "${pkgs.hyprland}/bin/Hyprland --config /etc/greetd/hyprland.conf";
        user = "greeter";
      };
    };
  };

  # --- REGREET CONFIG ---
  environment.etc."greetd/regreet.toml".text = ''
    [background]
    path = "/etc/greetd/wallpaper.png"
    fit = "Cover"

    [GTK]
    application_prefer_dark_theme = true
    theme_name = "Adwaita-dark"
    font_name = "Inter 12"
  '';

  # Copy wallpaper into /etc/greetd so regreet can access it as greeter user
  environment.etc."greetd/wallpaper.png".source = ../../assets/wallpapers/788530.png;

  # --- REGREET CSS ---
  environment.etc."greetd/regreet.css".text = ''
    window {
      background: transparent;
    }

    box#main-box {
      background: rgba(38, 38, 38, 0.92);
      border: none;
      border-radius: 12px;
      padding: 32px 40px;
      box-shadow: 0 4px 24px rgba(0, 0, 0, 0.6);
    }

    entry, combobox entry {
      background: rgba(55, 55, 55, 0.95);
      border: 1px solid rgba(255, 255, 255, 0.08);
      border-radius: 8px;
      color: #ffffff;
      padding: 10px 14px;
    }
    entry:focus {
      border-color: rgba(255, 255, 255, 0.25);
      background: rgba(65, 65, 65, 0.95);
    }

    combobox button, button {
      background: rgba(55, 55, 55, 0.9);
      border: 1px solid rgba(255, 255, 255, 0.08);
      border-radius: 8px;
      color: #ffffff;
    }
    combobox button:hover, button:hover {
      background: rgba(75, 75, 75, 0.9);
    }

    button#login-button {
      background: #e09b2d;
      border: none;
      font-weight: bold;
      padding: 8px 20px;
    }
    button#login-button:hover {
      background: #c98a20;
    }

    button#reboot-button,
    button#poweroff-button {
      background: rgba(220, 80, 80, 0.85);
      border: none;
      font-weight: bold;
      padding: 8px 20px;
    }
    button#reboot-button:hover,
    button#poweroff-button:hover {
      background: rgba(200, 60, 60, 0.95);
    }

    label {
      color: rgba(255, 255, 255, 0.88);
    }

    label#clock-label {
      font-size: 14px;
      font-weight: 600;
      color: #ffffff;
      background: rgba(38, 38, 38, 0.85);
      border-radius: 8px;
      padding: 4px 14px;
    }
  '';

  # --- HYPRLAND GREETER CONFIG ---
  environment.etc."greetd/hyprland.conf".text = ''
    # AMD GPU — required for Hyprland to start without a logged-in user
    env = WLR_NO_HARDWARE_CURSORS,1
    env = LIBVA_DRIVER_NAME,radeonsi
    env = GBM_BACKEND,radeonsi

    # Launch regreet, then exit Hyprland when login completes
    exec-once = ${pkgs.regreet}/bin/regreet --config /etc/greetd/regreet.toml --style /etc/greetd/regreet.css; hyprctl dispatch exit

    # ----------------------------------------------------------------
    # MONITORS — fill in your actual outputs + resolutions
    # Run `hyprctl monitors` from your normal session to get the names
    # ----------------------------------------------------------------
    # Example:
    # monitor = DP-1,   1920x1080@144, 0x0,    1
    # monitor = HDMI-A-1, 1920x1080@60, 1920x0, 1

    # Catch-all: auto-configure any connected monitor
    monitor = , preferred, auto, 1

    # Minimal visuals — no need for animations/decorations in greeter
    animations {
      enabled = false
    }
    decoration {
      rounding = 0
      shadow {
        enabled = false
      }
      blur {
        enabled = false
      }
    }
    misc {
      disable_hyprland_logo = true
      disable_splash_rendering = true
      force_default_wallpaper = 0
    }
    input {
      kb_layout = us
    }
  '';

  environment.systemPackages = with pkgs; [
    greetd.regreet
    swayidle
  ];
}

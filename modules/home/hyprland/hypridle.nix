{ pkgs, ... }:
{
  home.packages = with pkgs; [
    wl-gammarelay-rs
  ];

  services.hypridle = {
    enable = true;

    settings = {
      general = {
        lock_cmd = "sh -c 'pidof hyprlock || hyprlock'";
        before_sleep_cmd = "sh -c 'pidof hyprlock || hyprlock'";
        inhibit_sleep = 3;
        after_sleep_cmd = "hyprctl dispatch dpms on && busctl --user set-property rs.wl-gammarelay / rs.wl.gammarelay Brightness d 1.0";
      };

      listener = [
        {
          timeout = 120;
          on-timeout = "busctl --user set-property rs.wl-gammarelay / rs.wl.gammarelay Brightness d 0.5";
          on-resume = "busctl --user set-property rs.wl-gammarelay / rs.wl.gammarelay Brightness d 1.0";
        }
        {
          #timeout = 140;
          #on-timeout = "sh -c 'pidof hyprlock || hyprlock'";
        }
        {
          #timeout = 180;
          #on-timeout = "hyprctl dispatch dpms off";
          #on-resume = "hyprctl dispatch dpms on";
        }
        {
          #timeout = 1800;
          #on-timeout = "systemctl suspend";
        }
      ];
    };
  };

  systemd.user.services.wl-gammarelay-rs = {
    Unit = {
      Description = "wl-gammarelay-rs";
      After = "graphical-session.target";
      PartOf = "graphical-session.target";
    };
    Service = {
      ExecStart = "${pkgs.wl-gammarelay-rs}/bin/wl-gammarelay-rs run";
      Restart = "on-failure";
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };
}

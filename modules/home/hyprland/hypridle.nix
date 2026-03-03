{ ... }:
{
  services.hypridle = {
    enable = true;

    settings = {
      general = {
        lock_cmd = "sh -c 'pidof hyprlock || hyprlock'";
        before_sleep_cmd = "sh -c 'pidof hyprlock || hyprlock'";
        inhibit_sleep = 3;
        after_sleep_cmd = "hyprctl dispatch dpms on";
      };

      listener = [
        {
          timeout = 120;
          # no on-timeout: used as a warning threshold
        }
        {
          timeout = 140;
          on-timeout = "sh -c 'pidof hyprlock || hyprlock'";
        }
        {
          timeout = 180;
          on-timeout = "hyprctl dispatch dpms off";
          on-resume = "hyprctl dispatch dpms on";
        }
        {
          timeout = 1800;
          on-timeout = "systemctl suspend";
        }
      ];
    };
  };
}

{
  vars,
  pkgs,
  lib,
  ...
}:
{
  programs.regreet = {
    enable = true;

    settings = {
      background = {
        path = "/etc/regreet/wallpaper.jpg";
        fit = "Cover";
      };
      GTK = lib.mkForce {
        icon_theme_name = "Adwaita";
        theme_name = "Adwaita-dark";
        cursor_theme_name = "Adwaita";
      };
      appearance = {
        greeting = "Wake up, ${vars.username}...";
      };
    };
  };

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${lib.getExe pkgs.cage} -s -- ${lib.getExe pkgs.greetd.regreet}";
        user = "greeter";
      };
    };
  };

  users.extraUsers.greeter = {
    extraGroups = [
      "video"
      "input"
    ];
  };
}

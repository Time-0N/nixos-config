{ pkgs, ... }:

{
  console = {
    keyMap = "sg";
    font = "${pkgs.terminus_font}/share/consolefonts/ter-v32n.psf.gz";
    packages = [ pkgs.terminus_font ];
  };

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command =
          let
            tuigreetFlags = [
              "--time"
              "--time-format '%a, %d %b %Y %H:%M'"
              "--remember"
              "--remember-user-session"
              "--user-menu"
              "--user-menu-min-uid 1000"
              "--user-menu-max-uid 60000"
              "--asterisks"
              "--greeting 'Welcome to the system!'"
              "--theme 'border=magenta;text=cyan;prompt=green;time=red;action=blue;button=yellow;container=black;input=red'"
              "--cmd Hyprland"
            ];
          in
          "${pkgs.tuigreet}/bin/tuigreet ${builtins.concatStringsSep " " tuigreetFlags}";
        user = "greeter";
      };
    };
  };

  environment.systemPackages = [ pkgs.tuigreet ];
}

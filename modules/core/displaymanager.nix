{
  vars,
  pkgs,
  lib,
  ...
}:
{
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = ''
          ${lib.getExe pkgs.tuigreet} \
            --time \
            --remember \
            --remember-user-session \
            --asterisks \
            --greeting "Arise my creation, ${vars.hostName}..." \
            --theme 'border=magenta;text=cyan;prompt=green;time=red;action=blue;button=yellow;container=black;input=red' \
            --cmd "uwsm start hyprland-uwsm.desktop"
        '';
        user = "greeter";
      };
    };
  };

  # Needs to be writable by tuigreet stores last session
  systemd.tmpfiles.rules = [
    "d /var/cache/tuigreet 0755 greeter greeter - -"
  ];
}

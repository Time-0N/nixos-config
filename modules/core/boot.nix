{
  pkgs,
  lib,
  vars,
  ...
}:

{
  boot = {
    kernelPackages = pkgs.linuxPackages_latest;

    # ── Bootloader ───────────────────────────────────────────────
    loader = {
      systemd-boot = {
        enable = !vars.secureBoot;
        configurationLimit = 20;
        consoleMode = "max";
        editor = false;
      };
      efi.canTouchEfiVariables = true;
      timeout = 3;
    };

    lanzaboote = lib.mkIf vars.secureBoot or false {
      enable = true;
      pkiBundle = "/var/lib/sbctl";
    };

    # ── Kernel params (quiet boot) ───────────────────────────────
    kernelParams = [
      "consoleblank=60"
      "quiet"
      "logo.nologo"
      "systemd.show_status=auto"
      "boot.shell_on_fail"
      "loglevel=3"
      "rd.systemd.show_status=auto"
      "rd.udev.log_level=3"
      "udev.log_priority=3"
    ];

    consoleLogLevel = 3;
    initrd.verbose = false;
  };

  environment.systemPackages = with pkgs; [ sbctl ];
}

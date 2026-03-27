{ pkgs, ... }:

{
  boot = {
    kernelPackages = pkgs.linuxPackages_latest;

    # ── Bootloader ───────────────────────────────────────────────
    loader = {
      systemd-boot.enable = false;
      efi.canTouchEfiVariables = true;
      grub = {
        enable = true;
        devices = [ "nodev" ];
        efiSupport = true;
        useOSProber = true;
        extraEntries = ''
          menuentry "UEFI Firmware Settings" --class efi --class settings --class uefi {
            fwsetup
          }
        '';
      };
    };

    # ── Kernel params (quiet boot) ───────────────────────────────
    kernelParams = [
      "consoleblank=60"
      "quiet"
      "systemd.show_status=auto"
      "splash"
      "boot.shell_on_fail"
      "loglevel=3"
      "rd.systemd.show_status=auto"
      "rd.udev.log_level=3"
      "udev.log_priority=3"
    ];

    consoleLogLevel = 3;
    initrd.verbose = false;
  };
}

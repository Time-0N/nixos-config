{ vars, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/core
  ];

  # ── Host-specific: Boot ────────────────────────────────────────

  boot.loader.systemd-boot.windows = {
    "Windows" = {
      title = "Windows";
      efiDeviceHandle = "HD0c1";
      sortKey = "z_windows";
    };
  };

  # ── Host-specific: Networking ──────────────────────────────────
  networking.hostName = vars.hostName;

  # ── Host-specific: GPU (AMD) ───────────────────────────────────
  boot.initrd.kernelModules = [ "amdgpu" ];

  # ── Host-specific: Kernel module blacklist (IEM drivers) ───────
  boot.blacklistedKernelModules = [
    "mei"
    "mei_me"
  ];

  zramSwap = {
    enable = true;
    memoryPercent = 50;
    algorithm = "zstd";
  };

  # ── Host-specific: Mount points ────────────────────────────────
  systemd.tmpfiles.rules = [
    "d /mnt/renegade 0755 timeon users -"
  ];
}

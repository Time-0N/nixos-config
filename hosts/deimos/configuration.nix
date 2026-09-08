{ vars, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./fprintd.nix
    ../../modules/core
  ];

  # ── Host-specific: Networking ──────────────────────────────────
  networking.hostName = vars.hostName;

  # ── Host-specific: GPU (AMD) ───────────────────────────────────
  boot.initrd.kernelModules = [ "i915" ];

  # Swap device
  swapDevices = [
    { device = "/swap/swapfile"; }
  ];

  # Hibernation
  boot.resumeDevice = "/dev/disk/by-uuid/271e1974-adc9-42cf-aec8-371fa70973ab";
  boot.kernelParams = [ "resume_offset=533760" ];
  powerManagement.enable = true;

  # ── Host-specific: Kernel module blacklist (IEM drivers) ───────
  boot.blacklistedKernelModules = [
    "mei"
    "mei_me"
  ];

  # Zram
  zramSwap = {
    enable = true;
    memoryPercent = 50;
    algorithm = "zstd";
  };

  # ── Host-specific: Mount points ────────────────────────────────
}

{ vars, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/core
  ];

  # ── Host-specific: Networking ──────────────────────────────────
  networking.hostName = vars.hostName;

  # ── Host-specific: GPU (AMD) ───────────────────────────────────
  boot.initrd.kernelModules = [ "i915" ];

  # Hibernation

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

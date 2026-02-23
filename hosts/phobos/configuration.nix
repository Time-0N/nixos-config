{ vars, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/core
  ];

  # ── Host-specific: DO NOT MODIFY GRUB THEMING
  boot.loader.grub.gfxmodeEfi = "2560x1600x32";

  # ── Host-specific: Networking ──────────────────────────────────
  networking.hostName = vars.hostName;

  # ── Host-specific: GPU (AMD) ───────────────────────────────────
  boot.initrd.kernelModules = [ "i915" ];

  # Hibernation
  boot.resumeDevice = "/dev/disk/by-uuid/01d98871-f1c4-4da0-8f30-ed6481781897";

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

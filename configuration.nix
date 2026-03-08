{
  pkgs,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
    ./modules/core/displaymanager.nix
  ];

  # --- BOOTLOADER ---
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.loader.systemd-boot.enable = false;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.grub = {
    enable = true;
    devices = [ "nodev" ];
    efiSupport = true;
    useOSProber = true;
    theme = ./dotfiles/grub/virtuaverse;
    extraEntries = ''
      menuentry "UEFI Firmware Settings" --class efi --class settings --class uefi {
        fwsetup
      }
    '';
  };

  # --- Kernel Params ---
  boot.kernelParams = [
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
  boot.consoleLogLevel = 3;
  boot.initrd.verbose = false;

  # --- NETWORKING ---
  networking.hostName = "mercury";
  networking.networkmanager.enable = true;

  # --- DISPLAY & GPU ---
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };
  boot.initrd.kernelModules = [ "amdgpu" ];

  # --- BLUETOOTH ---
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };
  services.blueman.enable = true;

  # --- FONTS ---
  fonts.packages = with pkgs; [
    # 1. JetBrains Mono Nerd Font
    nerd-fonts.jetbrains-mono

    # 2. Code New Roman Nerd Font
    nerd-fonts.code-new-roman

    # 3. Geist Mono Nerd Font
    nerd-fonts.geist-mono
  ];

  # --- SYSTEM-LEVEL PROGRAMS ---
  # Hyprland system enablement (handles drivers/portals)
  programs.hyprland.enable = true;

  programs.dconf.enable = true;

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
  };

  services.flatpak.enable = true;
  nixpkgs.config.allowUnfree = true;

  time.timeZone = "Europe/Zurich";

  # --- FILEMANAGER ---
  services.gvfs.enable = true;
  services.tumbler.enable = true;
  services.udisks2.enable = true;
  security.polkit.enable = true;
  environment.pathsToLink = [ "/share/thumbnailers" ];
  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
      if ((action.id == "org.freedesktop.udisks2.filesystem-mount" ||
           action.id == "org.freedesktop.udisks2.filesystem-mount-system") &&
          subject.isInGroup("wheel")) {
        return polkit.Result.YES;
      }
    });
  '';

  # --- IEM DRIVERS DISABLED ---
  boot.blacklistedKernelModules = [
    "mei"
    "mei_me"
  ];

  # --- SYSTEM PACKAGES ---
  # Only for essential "admin" tools.
  environment.systemPackages = with pkgs; [
    git
    vim
    wget
    curl
    fastfetch
    lsd
    pciutils
    usbutils
    cage
  ];

  # --- USER DEFINITION ---
  users.users.timeon = {
    isNormalUser = true;
    description = "timeon";
    extraGroups = [
      "networkmanager"
      "wheel"
      "input"
      "video"
      "storage"
    ];
    shell = pkgs.zsh;
  };

  programs.zsh.enable = true;

  programs.gamemode.enable = true;

  # --- NIX SETTINGS ---
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  # --- Permissions ---
  systemd.tmpfiles.rules = [
    "d /mnt/renegade 0755 timeon users -"
  ];

  system.stateVersion = "24.11";
  nix.settings.auto-optimise-store = true;
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };
}

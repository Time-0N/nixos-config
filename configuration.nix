{
  config,
  pkgs,
  inputs,
  ...
}:

{
  imports = [ ./hardware-configuration.nix ];

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

  # --- NETWORKING ---
  networking.hostName = "mercury";
  networking.networkmanager.enable = true;

  # --- DISPLAY & GPU ---
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };
  services.xserver = {
    enable = true;
    videoDrivers = [ "amdgpu" ];
  };

  # --- BLUETOOTH ---
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
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

  # --- DISPLAY MANAGER ---
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.cage}/bin/cage -s -- ${pkgs.greetd.regreet}/bin/regreet";
        user = "greeter";
      };
    };
  };

  # --- SYSTEM-LEVEL PROGRAMS ---
  # Hyprland system enablement (handles drivers/portals)
  programs.hyprland.enable = true;

  programs.steam = {
    enable = true;
    gamescopeSession.enable = true;
    remotePlay.openFirewall = true;
  };

  services.flatpak.enable = true;
  nixpkgs.config.allowUnfree = true;

  time.timeZone = "Europe/Zurich";

  # --- NAUTILUS ---
  services.gvfs.enable = true;
  services.tumbler.enable = true;
  services.udisks2.enable = true;
  security.polkit.enable = true;

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

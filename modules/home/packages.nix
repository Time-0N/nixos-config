{ pkgs, inputs, ... }:
{
  home.packages = with pkgs; [
    # Build tools
    gcc
    gnumake
    unzip
    nodejs

    # Desktop apps
    vesktop
    vlc
    imv
    evince
    pinta
    gimp2-with-plugins
    (prismlauncher.override {
      jdks = [
        jdk8
        jdk17
        jdk21
      ];
    })
    qbittorrent
    protonvpn-gui
    proton-vpn-cli
    jellyfin-media-player
    trayscale

    # Android dev
    android-tools

    # File managers
    yazi

    # Cli tools
    lsd
    ffmpeg
    flac

    # Wayland / Hyprland utilities
    grim
    slurp
    satty
    wl-clipboard
    playerctl
    nwg-displays
    wlr-randr
    wlogout
    pavucontrol
    cava
    blueman
    ffmpegthumbnailer
    screen

    # Theming
    papirus-icon-theme

    # Wine and Proton
    wineWow64Packages.staging
    winetricks
    protonup-qt

    # Language runtimes
    rustc
    cargo
    python3
    ghc

    # Flake packages
    inputs.hypr-bucket.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
}

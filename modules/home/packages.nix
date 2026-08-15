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
    evince
    swayimg
    pinta
    gimp3-with-plugins
    (prismlauncher.override {
      jdks = [
        jdk8
        jdk17
        jdk21
        jdk25
      ];
    })
    qbittorrent
    proton-vpn
    jellyfin-desktop
    fuzzel # Clipboard selector
    trayscale
    kid3
    clonehero
    r2modman
    ungoogled-chromium

    # 3D
    #temp removed due to upstream test failure: freecad
    openscad
    blender

    # Android dev
    android-tools

    # File managers
    yazi

    # Cli tools
    lsd
    ffmpeg
    flac

    # Monitoring
    btop

    # Wayland / Hyprland utilities
    grim
    slurp
    satty
    wl-clipboard
    playerctl
    nwg-displays
    wlr-randr
    # wlogout is installed by programs.wlogout in ./wlogout.nix, which owns its
    # layout and stylesheet too. Listing it here as well would work but would
    # hide where it is actually configured.
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

    # Clanker tooling
    opencode
    claude-code

    # Flake packages
    inputs.hypr-bucket.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
}

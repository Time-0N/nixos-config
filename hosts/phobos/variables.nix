{
  username = "timeon";
  hostName = "phobos";

  gitUsername = "Time-0N";
  gitEmail = "timeon.haas@gmail.com";
  gitGpgKey = "E1D08EE6A0B70A69";

  timeZone = "Europe/Zurich";

  browser = "zen";
  terminal = "kitty";

  tailscale = true;

  # GUI - Waybar
  enableLaptopMode = true;

  mimeDefaultApps = {
    # File Manager
    "inode/directory" = [ "org.gnome.Nautilus.desktop" ];

    # Text Editor
    "text/plain" = [ "neovim-kitty.desktop" ];
    "text/markdown" = [ "neovim-kitty.desktop" ];
    "text/x-python" = [ "neovim-kitty.desktop" ];
    "text/x-shellscript" = [ "neovim-kitty.desktop" ];
    "text/x-c" = [ "neovim-kitty.desktop" ];
    "text/x-rust" = [ "neovim-kitty.desktop" ];
    "application/json" = [ "neovim-kitty.desktop" ];
    "text/xml" = [ "neovim-kitty.desktop" ];

    # Images
    "image/jpeg" = [ "imv.desktop" ];
    "image/png" = [ "imv.desktop" ];
    "image/gif" = [ "imv.desktop" ];
    "image/webp" = [ "imv.desktop" ];
    "image/svg+xml" = [ "imv.desktop" ];

    # Audio & Video
    "video/mp4" = [ "vlc.desktop" ];
    "video/x-matroska" = [ "vlc.desktop" ];
    "video/webm" = [ "vlc.desktop" ];
    "video/x-msvideo" = [ "vlc.desktop" ];
    "audio/mpeg" = [ "vlc.desktop" ];
    "audio/flac" = [ "vlc.desktop" ];
    "audio/ogg" = [ "vlc.desktop" ];
    "audio/x-wav" = [ "vlc.desktop" ];

    # Documents
    "application/pdf" = [ "org.gnome.Evince.desktop" ];
    "application/postscript" = [ "org.gnome.Evince.desktop" ];

    # Torrents
    "application/x-bittorrent" = [ "org.qbittorrent.qBittorrent.desktop" ];
    "x-scheme-handler/magnet" = [ "org.qbittorrent.qBittorrent.desktop" ];
  };
}

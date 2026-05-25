{ pkgs, lib, ... }:

pkgs.flutter.buildFlutterApplication rec {
  pname = "musly";
  version = "unstable-2024";

  src = pkgs.fetchFromGitHub {
    owner = "dddevid";
    repo = "musly";
    rev = "main";
    hash = "sha256-c96QIFvycKZScNtxTwwwmfPZGWuu5Fp/zOh1lXjmyDU=";
  };

  autoPubspecLock = "${src}/pubspec.lock";

  nativeBuildInputs = with pkgs; [
    pkg-config
    makeWrapper
    copyDesktopItems
  ];

  buildInputs = with pkgs; [
    gtk3
    glib
    pango
    cairo
    harfbuzz
    atk
    mpv
    libnotify
    alsa-lib
  ];

  desktopItems = [
    (pkgs.makeDesktopItem {
      name = "musly";
      desktopName = "Musly";
      exec = "musly";
      icon = "audio-x-generic";
      comment = "Subsonic/Navidrome client";
      categories = [
        "AudioVideo"
        "Audio"
        "Player"
      ];
      terminal = false;
    })
  ];

  meta = with lib; {
    description = "A Subsonic/Navidrome client";
    homepage = "https://github.com/dddevid/musly";
    license = licenses.cc-by-nc-sa-40;
    platforms = platforms.linux;
  };

  postFixup = ''
    wrapProgram $out/bin/musly \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [ pkgs.mpv-unwrapped ]}
  '';
}

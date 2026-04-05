{ lib, pkgs, ... }:
{
  home.packages = with pkgs; [
    libsForQt5.qt5ct
    qt6Packages.qt6ct
    libsForQt5.qtstyleplugin-kvantum
    qt6Packages.qtstyleplugin-kvantum
    (catppuccin-kvantum.override {
      accent = "blue";
      variant = "mocha";
    })
  ];

  qt = {
    enable = true;
    platformTheme.name = lib.mkForce "qtct";
    style.name = lib.mkForce "kvantum";
  };

  xdg.configFile = {
    "Kvantum/catppuccin-mocha-blue".source = "${
      pkgs.catppuccin-kvantum.override {
        accent = "blue";
        variant = "mocha";
      }
    }/share/Kvantum/catppuccin-mocha-blue";
    "Kvantum/kvantum.kvconfig".text = ''
      [General]
      theme=catppuccin-mocha-blue
    '';
  };
}

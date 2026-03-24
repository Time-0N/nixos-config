{ lib, pkgs, ... }:
{
  home.packages = with pkgs; [
    libsForQt5.qt5ct
    qt6Packages.qt6ct
    libsForQt5.qtstyleplugin-kvantum
    qt6Packages.qtstyleplugin-kvantum
    orchis-theme
  ];

  qt = {
    enable = true;
    platformTheme.name = lib.mkForce "qtct";
    style.name = lib.mkForce "kvantum";
  };
}

{ ... }:

{
  imports = [
    ./boot.nix
    ./greetd.nix
    ./bluetooth.nix
    ./fonts.nix
    ./gpu.nix
    ./networking.nix
    ./filemanager.nix
    ./programs.nix
    ./users.nix
    ./nix.nix
    ./flatpak.nix
  ];
}

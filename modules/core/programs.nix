{ pkgs, vars, ... }:

{
  programs.hyprland = {
    enable = true;
    withUWSM = true;
  };
  programs.dconf.enable = true;
  programs.zsh.enable = true;
  programs.gamemode.enable = true;

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
  };

  nixpkgs.config.allowUnfree = true;

  time.timeZone = vars.timeZone;

  environment.systemPackages = with pkgs; [
    brightnessctl
    parted
    wget
    curl
    pciutils
    usbutils
    cage
    snapper
  ];
}

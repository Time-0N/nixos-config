{ pkgs, ... }:

{
  fonts = {
    packages = with pkgs; [
      nerd-fonts.jetbrains-mono
      nerd-fonts.code-new-roman
      nerd-fonts.geist-mono
      open-sans
      overpass
    ];
    fontconfig.enable = true;
  };
}

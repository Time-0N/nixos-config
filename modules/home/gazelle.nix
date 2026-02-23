{ inputs, pkgs, ... }:
{
  imports = [ inputs.gazelle.homeModules.gazelle ];

  home.packages = [
    inputs.gazelle.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];

  programs.gazelle = {
    enable = true;
    settings = {
      theme = "nord";
    };
  };
}

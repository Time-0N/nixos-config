{ pkgs, ... }:

{
  console = {
    keyMap = "sg";
    font = "${pkgs.terminus_font}/share/consolefonts/ter-v32n.psf.gz";
    packages = [ pkgs.terminus_font ];
  };
}

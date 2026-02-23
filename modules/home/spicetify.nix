{ pkgs, inputs, ... }:
let
  spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.stdenv.hostPlatform.system};
in
{
  imports = [ inputs.spicetify-nix.homeManagerModules.default ];

  programs.spicetify = {
    enable = true;
    enabledExtensions = with spicePkgs.extensions; [
      adblock
      hidePodcasts
      shuffle
    ];
    theme = {
      name = "Blossom";
      src =
        pkgs.fetchFromGitHub {
          owner = "spicetify";
          repo = "spicetify-themes";
          rev = "master";
          hash = "sha256-mP4YXeXtOR7+YA8KmRMOEsxjPhjPiyId1gpatlvK/5M=";
        }
        + "/Blossom";
      injectCss = true;
      injectThemeJs = false;
      replaceColors = true;
      homeConfig = false;
      overwriteAssets = false;
    };
  };
}

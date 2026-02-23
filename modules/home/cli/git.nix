{
  vars,
  pkgs,
  lib,
  ...
}:
let
  hasGpg = vars ? gitGpgKey && vars.gitGpgKey != null && vars.gitGpgKey != "";
in
{
  programs.git = {
    enable = true;
    settings.user = {
      name = vars.gitUsername;
      email = vars.gitEmail;
    };

    signing = lib.mkIf hasGpg {
      key = vars.gitGpgKey;
      signByDefault = true;
    };
  };

  programs.gpg.enable = true;

  services.gpg-agent = {
    enable = true;
    defaultCacheTtl = 3600;
    maxCacheTtl = 7200;
    pinentry.package = pkgs.pinentry-qt;
  };
}

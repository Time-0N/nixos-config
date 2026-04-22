{ inputs, pkgs, ... }:
let
  zen = inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default.override {
    extraPolicies = {
      DontCheckDefaultBrowser = true;
      DisableAppUpdate = true;
      DisableTelemetry = true;
    };
  };
in
{
  home.packages = [ zen ];
}

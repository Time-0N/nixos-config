{ vars, lib, ... }:
{
  services.tailscale = lib.mkIf (vars ? tailscale && vars.tailscale) {
    enable = true;
    useRoutingFeatures = "client";
    extraSetFlags = [ "--operator=${vars.username}" ];
  };
}

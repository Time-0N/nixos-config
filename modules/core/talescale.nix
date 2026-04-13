{ vars, lib, ... }:
{
  services.tailscale.enable = lib.mkIf (vars ? tailscale && vars.tailscale) true;
}

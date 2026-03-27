{ pkgs, vars, ... }:
{
  users.users.timeon = {
    isNormalUser = true;
    description = vars.username;
    extraGroups = [
      "networkmanager"
      "wheel"
      "input"
      "video"
      "storage"
    ];
    shell = pkgs.zsh;
  };
}

{ pkgs, vars, ... }:
{
  users.users.${vars.username} = {
    isNormalUser = true;
    description = vars.username;
    extraGroups = [
      "networkmanager"
      "wheel"
      "input"
      "video"
      "storage"
      "adbusers"
      "kvm"
      "docker"
    ];
    shell = pkgs.zsh;
  };
}

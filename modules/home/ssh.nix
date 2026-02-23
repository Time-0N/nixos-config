{ ... }:

{
  programs.ssh = {
    enable = true;
    matchBlocks."*".addKeysToAgent = "yes";
    enableDefaultConfig = false;
  };

  services.ssh-agent.enable = true;
}

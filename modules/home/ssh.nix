{ ... }:

{
  programs.ssh = {
    enable = true;
    settings."*".addKeysToAgent = "yes";
    enableDefaultConfig = false;
  };

  services.ssh-agent.enable = true;
}

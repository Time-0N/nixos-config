{ vars, ... }:
{
  imports = [
    ./cli/git.nix
    ./cli/lazygit.nix
    ./packages.nix
    ./ssh.nix
    ./zsh.nix
    ./gtk.nix
    ./qt.nix
    ./gazelle.nix
    ./waybar
    ./hyprland
    ./starship.nix
    ./kitty.nix
    ./zen-browser.nix
    ./nixvim
  ];

  home.username = vars.username;
  home.homeDirectory = "/home/${vars.username}";
  home.sessionVariables = {
    BROWSER = vars.browser;
    TERMINAL = vars.terminal;
  };
  home.stateVersion = "24.11";

  programs.home-manager.enable = true;
}

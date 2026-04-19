{ vars, ... }:
{
  imports = [
    ./direnv.nix
    ./nautilus.nix
    ./xdg.nix
    ./desktop-entries.nix
    ./cli/git.nix
    ./cli/lazygit.nix
    ./fastfetch
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
    ./spicetify.nix
  ];

  home.username = vars.username;
  home.homeDirectory = "/home/${vars.username}";
  home.sessionVariables = {
    TERMINAL = vars.terminal;
  };
  home.stateVersion = "24.11";

  programs.home-manager.enable = true;
}

{ pkgs }:

let
  hyprland = import ./hyprland { inherit pkgs; };
  waybar = import ./waybar { inherit pkgs; };
in
builtins.attrValues (hyprland // waybar)

{ pkgs, ... }:
{
  xdg.desktopEntries.neovim-kitty = {
    name = "Neovim (Kitty)";
    exec = "kitty nvim %F";
    type = "Application";
    mimeType = [
      "text/plain"
      "text/x-python"
      "text/x-shellscript"
      "text/x-c"
      "text/x-rust"
      "text/markdown"
    ];
    icon = "nvim";
  };
}

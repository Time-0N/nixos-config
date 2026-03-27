{ pkgs, ... }:

{
  imports = [
    ./keymaps.nix
    ./plugins/treesitter.nix
    ./plugins/lsp.nix
    ./plugins/conform.nix
    ./plugins/completion.nix
    ./plugins/telescope.nix
    ./plugins/ui.nix
    ./plugins/editor.nix
    ./plugins/autosave.nix
  ];

  programs.nixvim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;

    colorschemes.tokyonight = {
      enable = true;
      settings.style = "moon";
    };

    opts = {
      number = true;
      relativenumber = true;
      shiftwidth = 2;
      tabstop = 2;
      expandtab = true;
      smartindent = true;
      wrap = false;
      termguicolors = true;
      signcolumn = "yes";
      cursorline = true;
      scrolloff = 8;
      sidescrolloff = 8;
      clipboard = "unnamedplus";
      undofile = true;
      ignorecase = true;
      smartcase = true;
      splitbelow = true;
      splitright = true;
      mouse = "a";
      showmode = false;
      updatetime = 250;
      timeoutlen = 300;
    };

    globals = {
      mapleader = " ";
      maplocalleader = "\\";
    };

    extraPackages = with pkgs; [
      ripgrep
      fd
    ];
  };
}

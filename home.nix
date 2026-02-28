{
  config,
  pkgs,
  inputs,
  ...
}:

let
  nixScripts = import ./scripts { inherit pkgs; };

in
{
  imports = [ ./modules/waybar ];

  home.username = "timeon";
  home.homeDirectory = "/home/timeon";
  home.stateVersion = "24.11";

  # User-specific packages (Moving them from configuration.nix)
  home.packages = [
    pkgs.gcc
    pkgs.gnumake
    pkgs.unzip
    pkgs.nodejs

    pkgs.vesktop
    pkgs.kitty
    pkgs.grim
    pkgs.slurp
    pkgs.satty
    pkgs.wl-clipboard
    pkgs.hypridle
    pkgs.hyprlock
    pkgs.swww
    pkgs.playerctl
    pkgs.nwg-displays
    pkgs.wlr-randr
    pkgs.zsh-powerlevel10k
    pkgs.wlogout
    pkgs.pavucontrol
    pkgs.cava
    pkgs.blueman
    pkgs.spotify
    pkgs.parted
    pkgs.vlc
    pkgs.imv
    pkgs.evince
    pkgs.ffmpegthumbnailer
    pkgs.nautilus
    pkgs.pinta

    pkgs.papirus-icon-theme
    pkgs.apple-cursor

    # Wine and Proton
    pkgs.wineWowPackages.staging
    pkgs.winetricks
    pkgs.protonup-qt

    # Nix tools
    pkgs.nil
    pkgs.nixfmt-rfc-style

    # Rust tools
    pkgs.rust-analyzer
    pkgs.rustc
    pkgs.cargo

    # Python tools
    pkgs.pyright
    pkgs.python3
    pkgs.ruff

    # Haskell tools
    pkgs.haskell-language-server
    pkgs.ghc

    # Java tools
    pkgs.jdt-language-server
    pkgs.google-java-format

    # HTML, JSON, CSS, JS
    pkgs.prettierd
    pkgs.vscode-langservers-extracted

    # Typescript tools
    pkgs.vtsls

    # Bash tools
    pkgs.shfmt
    pkgs.bash-language-server

    # C, C++ tools
    pkgs.clang-tools

    # Ruby tools
    pkgs.ruby-lsp

    # Assembly (Intel/AT&T) tools
    pkgs.asm-lsp

    # XML tools
    pkgs.lemminx

    # Lua tools
    pkgs.stylua

    # Fixed theming packages
    pkgs.libsForQt5.qt5ct
    pkgs.qt6Packages.qt6ct
    pkgs.libsForQt5.qtstyleplugin-kvantum
    pkgs.qt6Packages.qtstyleplugin-kvantum

    # Zen Browser
    inputs.zen-browser.packages.${pkgs.system}.default

    # Hyprbucket
    inputs.hypr-bucket.packages.${pkgs.system}.default
  ]
  ++ nixScripts;

  # AUTOMATIC DOTFILES: This links your dotfile folders directly
  xdg.configFile = {
    "hypr".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos-config/dotfiles/hypr";
    "nvim".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos-config/dotfiles/nvim";
    "kitty".source = ./dotfiles/kitty;
    "gtk-3.0".source = ./dotfiles/gtk-3.0;
    "gtk-4.0".source = ./dotfiles/gtk-4.0;
    "Kvantum".source = ./dotfiles/Kvantum;
    "hyprlock".source = ./dotfiles/hyprlock;
  };

  home.file = {
    ".p10k.zsh".source = ./dotfiles/.p10k.zsh;
  };

  home.sessionVariables = {
    EDITOR = "nvim";
    BROWSER = "zen";
    TERMINAL = "kitty";
    # Add other vars here
  };

  # --- PROGRAMS ---
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    extraPackages = with pkgs; [
      # Nix
      nil
      alejandra

      # Python
      pyright
      python3
      sqlfluff

      # Rust
      rust-analyzer
      rustc
      cargo

      # Haskell
      haskell-language-server
      ghc

      # Lua
      lua-language-server

      # General tooling
      ripgrep
      fd
    ];
    plugins = [
      pkgs.vimPlugins.nvim-treesitter.withAllGrammars
      pkgs.vimPlugins.nvim-lspconfig
    ];

  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;

    # 2. STANDARD PLUGINS
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    oh-my-zsh = {
      enable = true;
      plugins = [ "git" ];
    };

    # 3. ENVIRONMENT VARIABLES
    sessionVariables = {
      ANDROID_HOME = "$HOME/Android/Sdk";
      BUNDLE_PATH = "$HOME/.gem";
      EDITOR = "nvim";
    };

    shellAliases = {
      vim = "nvim";
      zen = "zen-browser";
      ls = "lsd";
    };

    # 4. INSTANT PROMPT (Goes at the very top)
    initExtraFirst = ''
      if [[ -r "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh" ]]; then
        source "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh"
      fi
    '';

    # 5. MAIN CONFIGURATION
    initExtra = ''
      source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme

      # PATH Exports
      export PATH="$HOME/.local/share/gem/ruby/3.4.0/bin:$PATH"
      export PATH="$PATH:$ANDROID_HOME/emulator"
      export PATH="$PATH:$ANDROID_HOME/platform-tools"
      export PATH="$HOME/.local/bin:$PATH"

      # GHCUP
      [ -f "${config.home.homeDirectory}./.ghcup/env" ] && . "/home/timeon/.ghcup/env"

      # Powerlevel10k Config
      # (Ensure .p10k.zsh is actually sourced via home.file in this same file)
      [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
    '';
  };

  programs.ssh = {
    enable = true;
    addKeysToAgent = "yes";
  };

  services.ssh-agent.enable = true;
  # --- END OF PROGRAMS

  xdg.userDirs = {
    enable = true;
    createDirectories = true; # Automatically create them if they don't exist

    download = "${config.home.homeDirectory}/downloads";
    documents = "${config.home.homeDirectory}/documents";
    music = "${config.home.homeDirectory}/music";
    pictures = "${config.home.homeDirectory}/pictures";
    videos = "${config.home.homeDirectory}/videos";
    desktop = "${config.home.homeDirectory}/desktop";
    publicShare = "${config.home.homeDirectory}/public";
    templates = "${config.home.homeDirectory}/templates";
  };

  # This handles GTK 2/3/4 and icon themes
  gtk = {
    enable = true;
    theme = {
      name = "Materia-dark";
      package = pkgs.materia-theme;
    };
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
    cursorTheme = {
      name = "macOS";
      package = pkgs.apple-cursor;
      size = 24;
    };
  };

  # This is for dark theme in GNOME apps under hyprland
  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
    };
  };

  # This forces the cursor to work across Hyprland and XWayland apps
  home.pointerCursor = {
    gtk.enable = true;
    package = pkgs.apple-cursor;
    name = "macOS";
    size = 24;
  };

  # Let Home Manager install and manage itself
  programs.home-manager.enable = true;

}

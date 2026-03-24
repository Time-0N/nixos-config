{
  lib,
  config,
  pkgs,
  inputs,
  vars,
  ...
}:

{
  imports = [
    ./modules/home/default.nix
  ];

  home.username = "timeon";
  home.homeDirectory = "/home/timeon";
  home.stateVersion = "24.11";

  # User-specific packages
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
    pkgs.playerctl
    pkgs.nwg-displays
    pkgs.wlr-randr
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
    pkgs.nemo
    pkgs.pinta
    pkgs.yazi
    pkgs.screen
    pkgs.gimp2-with-plugins

    pkgs.papirus-icon-theme

    # Wine and Proton
    pkgs.wineWow64Packages.staging
    pkgs.winetricks
    pkgs.protonup-qt

    # Nix tools
    pkgs.nil
    pkgs.nixfmt

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

    # Hyprbucket
    inputs.hypr-bucket.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];

  # AUTOMATIC DOTFILES: This links your dotfile folders directly
  xdg.configFile = {
    "nvim".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos-config/dotfiles/nvim";
    "kitty".source = ./dotfiles/kitty;
    "Kvantum".source = ./dotfiles/Kvantum;
  };

  home.sessionVariables = {
    EDITOR = "nvim";
    BROWSER = vars.browser;
    TERMINAL = vars.terminal;
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
      nixsw = "sudo nixos-rebuild switch --flake ~/nixos-config";
    };

    # Transient prompt for starship (not natively supported in zsh)
    initContent = lib.mkAfter ''
      autoload -Uz add-zsh-hook
      add-zsh-hook precmd transient-prompt-precmd

      TRANSIENT_PROMPT="''${PROMPT// prompt / prompt --profile transient }"
      TRANSIENT_RPROMPT="''${PROMPT// prompt / prompt --profile rtransient }"

      function transient-prompt-precmd {
        TRAPINT() { transient-prompt; return $(( 128 + $1 )) }
        SAVED_PROMPT="$(eval "printf '%s' \"''${TRANSIENT_PROMPT}\"")"
        SAVED_RPROMPT="$(eval "printf '%s' \"''${TRANSIENT_RPROMPT}\"")"
      }

      autoload -Uz add-zle-hook-widget
      add-zle-hook-widget zle-line-finish transient-prompt

      function transient-prompt() {
        PROMPT="$SAVED_PROMPT" RPROMPT="$SAVED_RPROMPT" zle .reset-prompt
      }
    '';

  };

  programs.ssh = {
    enable = true;
    matchBlocks."*".addKeysToAgent = "yes";
  };

  services.ssh-agent.enable = true;
  # --- END OF PROGRAMS

  # Let Home Manager install and manage itself
  programs.home-manager.enable = true;

}

{ lib, config, ... }:
{
  programs.zsh = {
    enable = true;
    enableCompletion = true;

    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    dotDir = config.home.homeDirectory;

    oh-my-zsh = {
      enable = true;
      plugins = [ "git" ];
    };

    # 3. ENVIRONMENT VARIABLES
    sessionVariables = {
      ANDROID_HOME = "$HOME/Android/Sdk";
      BUNDLE_PATH = "$HOME/.gem";
    };

    shellAliases = {
      lg = "lazygit";
      ff = "fastfetch";
      ls = "lsd";
      nixsw = "sudo nixos-rebuild switch --flake ~/nixos-config";
      nixgc = "sudo nix-collect-garbage --delete-older-than 7d && nix-collect-garbage --delete-older-than 7d";
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
}

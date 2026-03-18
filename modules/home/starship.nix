{ pkgs, ... }:
{
  programs.starship = {
    enable = true;
    package = pkgs.starship;
    settings = {
      "$schema" = "https://starship.rs/config-schema.json";

      format =
        "[░▒▓](fg:white)"
        + "[ 󱄅 ](bg:white fg:nix-blue)"
        + "$username"
        + "[](fg:white bg:blue)"
        + "[ $directory ](bg:blue fg:#e4e4e4)"
        + "$git_branch"
        + "$git_status"
        + "$status"
        + "$cmd_duration"
        + "$jobs"
        + "[](fg:white)"
        + "[ $time ](bg:white fg:#080808)"
        + "[▓▒░](fg:white)"
        + "$line_break"
        + "$character";

      add_newline = true;

      palette = "timertheme";

      palettes.timertheme = {
        color_white = "#e4e4e4";
        color_nixblue = "#7ebae4";
        color_bg1 = "#3c3836";
        color_bg3 = "#665c54";
      };

      directory = {
        format = "[$path]($style)[$read_only]($read_only_style)";
        style = "bg:blue fg:#e4e4e4 bold";
        read_only = " 󰌾";
        read_only_style = "bg:blue fg:#e4e4e4";
        truncation_length = 3;
        truncate_to_repo = true;
        truncation_symbol = "…/";
        repo_root_style = "bg:blue fg:white bold";
        substitutions = {
          "documents" = "󰈙 ";
          "downloads" = " ";
          "music" = "󰝚 ";
          "pictures" = " ";
          "developer" = "󰲋 ";
        };
      };

      git_branch = {
        format = "[](fg:blue bg:green)[ $symbol$branch(:$remote_branch) ]($style)";
        style = "bg:green fg:#080808";
        symbol = " ";
        truncation_length = 32;
        truncation_symbol = "…";
      };

      git_status = {
        format = "([$all_status$ahead_behind ]($style))[](fg:green)";
        style = "bg:green fg:#080808";
        ahead = "⇡$count";
        behind = "⇣$count";
        diverged = "⇣$behind_count⇡$ahead_count";
        stashed = "*$count";
        conflicted = "~$count";
        staged = "+$count";
        modified = "!$count";
        untracked = "?$count";
        deleted = "";
        renamed = "";
      };

      character = {
        success_symbol = "[❯](bold green)";
        error_symbol = "[❯](bold red)";
        vimcmd_symbol = "[❮](bold green)";
        vimcmd_replace_one_symbol = "[▶](bold green)";
        vimcmd_visual_symbol = "[V](bold green)";
      };

      status = {
        format = "[$symbol$status ]($style)";
        style = "fg:yellow";
        symbol = "✘ ";
        signal_symbol = "✘ ";
        disabled = false;
      };

      cmd_duration = {
        format = "[$duration ]($style)";
        style = "fg:yellow";
        min_time = 3000;
        show_milliseconds = false;
      };

      jobs = {
        format = "[$symbol]($style)";
        style = "fg:cyan bold";
        symbol = "⚙ ";
        number_threshold = 1;
        symbol_threshold = 1;
      };

      time = {
        format = "[$time]($style)";
        style = "bg:white fg:#080808";
        time_format = "%H:%M:%S";
        disabled = false;
      };

      username = {
        format = "[$user]($style)";
        style_user = "bg:white fg:nix-blue";
        style_root = "bg:white fg:red bold";
        show_always = true;
      };

      hostname = {
        format = "[@$hostname ]($style)";
        style = "fg:yellow";
        ssh_only = true;
      };

      python = {
        format = "[\${symbol}\${pyenv_prefix}(\${version} )(\($virtualenv\) )]($style)";
        style = "fg:#080808 bg:blue";
        symbol = " ";
      };

      nodejs = {
        format = "[$symbol($version )]($style)";
        style = "fg:#080808 bg:green";
        symbol = " ";
      };

      golang = {
        format = "[$symbol($version )]($style)";
        style = "fg:#080808 bg:blue";
        symbol = " ";
      };

      rust = {
        format = "[$symbol($version )]($style)";
        style = "fg:#080808 bg:208";
        symbol = " ";
      };

      ruby = {
        format = "[$symbol($version )]($style)";
        style = "fg:#080808 bg:red";
        symbol = " ";
      };

      java = {
        format = "[$symbol($version )]($style)";
        style = "fg:red bg:white";
        symbol = " ";
      };

      lua = {
        format = "[$symbol($version )]($style)";
        style = "fg:#080808 bg:blue";
        symbol = " ";
      };

      php = {
        format = "[$symbol($version )]($style)";
        style = "fg:#080808 bg:magenta";
        symbol = " ";
      };

      haskell = {
        format = "[$symbol($version )]($style)";
        style = "fg:#080808 bg:yellow";
        symbol = " ";
      };

      elixir = {
        format = "[$symbol($version )]($style)";
        style = "fg:#080808 bg:magenta";
        symbol = " ";
      };

      erlang = {
        format = "[$symbol($version )]($style)";
        style = "fg:#080808 bg:red";
        symbol = " ";
      };

      dotnet = {
        format = "[$symbol($version )]($style)";
        style = "fg:white bg:magenta";
        symbol = "󰋚 ";
      };

      nix_shell = {
        format = "[$symbol$state( \\($name\\))]($style) ";
        style = "fg:#080808 bg:blue";
        symbol = " ";
      };

      terraform = {
        format = "[$symbol$workspace ]($style)";
        style = "fg:blue bg:black";
        symbol = "󱁢 ";
      };

      kubernetes = {
        format = "[$symbol$context( \\($namespace\\))]($style) ";
        style = "fg:white bg:blue";
        symbol = "󱃾 ";
        disabled = false;
      };

      aws = {
        format = "[$symbol($profile )(\\($region\\) )]($style)";
        style = "fg:white bg:red";
        symbol = "  ";
      };

      gcloud = {
        format = "[$symbol$account(@$domain)(\\($project\\))]($style) ";
        style = "fg:white bg:blue";
        symbol = " ";
      };

      direnv = {
        format = "[$symbol$loaded/$allowed]($style) ";
        style = "fg:yellow";
        symbol = "direnv ";
        disabled = false;
      };
    };
  };
}

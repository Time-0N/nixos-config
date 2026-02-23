{ pkgs, lib, ... }:
{
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    package = pkgs.starship;
    settings = {

      format = lib.concatStrings [
        "[░▒▓](color_black2)"
        "$os"
        "$time"
        "[](fg:color_black2 bg:color_green)"
        "$hostname"
        "$localip"
        "[](fg:color_green bg:color_blue2)"
        "$username"
        "[](fg:color_blue2 bg:color_yellow)"
        "$shlvl"
        "$sudo"
        "[](fg:color_yellow bg:color_red)"
        "$git_branch"
        "$git_status"
        "$package"
        "$docker_context"
        "[](fg:color_red bg:color_white3)"
        "$directory"
        "[](fg:color_white3)"
        "$line_break"
        "$character"
        "[ ](fg:color_fg)"
      ];

      right_format = lib.concatStrings [
        "$status"
        "$cmd_duration"
      ];

      line_break = {
        disabled = false;
      };

      add_newline = true;

      palette = "timertheme";

      palettes.timertheme = {
        color_fg = "#d8dee9";
        color_bg = "#2e3440";
        color_red = "#bf616a";
        color_green = "#a3be8c";
        color_purple = "#b48ead";
        color_yellow = "#ebcb8b";
        color_orange = "#d08770";
        color_white1 = "#eceff4";
        color_white2 = "#e5e9f0";
        color_white3 = "#d8dee9";
        color_black1 = "#2e3440";
        color_black2 = "#3b4252";
        color_black3 = "#434c5e";
        color_black4 = "#4c566a";
        color_blue1 = "#5e81ac";
        color_blue2 = "#81a1c1";
        color_blue3 = "#88c0d0";
        color_blue4 = "#8fbcbb";
      };

      directory = {
        disabled = false;
        read_only = "";
        home_symbol = " ";
        truncation_length = 6;
        truncate_to_repo = true;
        truncation_symbol = " /";
        #substitutions = {
        #  "documents" = "󰈙 documents";
        #  "downloads" = " downloads";
        #  "music" = "󰝚 music";
        #  "pictures" = " pictures";
        #  "developer" = "󰲋 developer";
        #};
        read_only_style = "fg:color_red bg:color_white3";
        style = "fg:color_bg bg:color_white3";
        format = "($style)[$read_only]($read_only_style)[ $path ]($style)";
      };

      # Transient prompt for zsh
      profiles = {
        transient = lib.concatStrings [
          "$character"
        ];
        rtransient = lib.concatStrings [
          "$status"
          "$cmd_duration"
        ];
      };

      git_branch = {
        symbol = "";
        style = "bg:color_red";
        format = "[[ $symbol $branch ](fg:color_fg bg:color_red)]($style)";
        truncation_length = 32;
        truncation_symbol = "…";
      };

      git_status = {
        style = "bg:color_red";
        format = "[[($all_status$ahead_behind )](fg:color_fg bg:color_red)]($style)";
      };

      character = {
        disabled = false;
        success_symbol = "[❯](bold fg:color_green)";
        error_symbol = "[❯](bold fg:color_red)";
        vimcmd_symbol = "[❮](bold fg:color_green)";
        vimcmd_replace_one_symbol = "[▶](bold fg:color_purple)";
        vimcmd_replace_symbol = "[▶](bold fg:color_purple)";
        vimcmd_visual_symbol = "[V](bold fg:color_yellow)";
      };

      status = {
        format = "[$symbol$status ]($style)";
        style = "fg:yellow";
        symbol = "✘ ";
        signal_symbol = "✘ ";
        disabled = false;
      };

      cmd_duration = {
        style = "fg:color_fg";
        format = "[  $duration ]($style)";
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
        disabled = false;
        time_format = "%H:%M";
        style = "bg:color_black2";
        format = "[[   $time ](fg:color_white3 bg:color_black2)]($style)";
      };

      username = {
        disabled = false;
        show_always = true;
        style_user = "fg:color_bg bg:color_blue2";
        style_root = "fg:color_red bg:color_blue2";
        format = "[  ]($style)[ $user ](fg:color_bg bg:color_blue2)";
      };

      hostname = {
        disabled = false;
        ssh_only = true;
        ssh_symbol = " 󱘖 "; # 󱘖    󰣀
        style = "fg:color_bg bg:color_green";
        format = "[$ssh_symbol]($style)[ 󰍹  $hostname ]($style)";
      };

      os = {
        disabled = false;
        style = "fg:color_white3 bg:color_black2";
        format = "[ $symbol ]($style)";
      };

      os.symbols = {
        NixOS = "󱄅";
      };

      localip = {
        disabled = false;
        ssh_only = true;
        style = "fg:color_bg bg:color_green";
        format = "[ 󰩟 $localipv4 ]($style)";
      };

      shlvl = {
        disabled = false;
        threshold = 2;
        symbol = "";
        style = "fg:color_bg bg:color_yellow";
        format = "[ $symbol $shlvl ]($style)";
      };

      sudo = {
        disabled = false;
        symbol = "󰌆 ";
        style = "fg:color_red bg:color_yellow";
        format = "[ $symbol ]($style)";
      };

      package = {
        format = "[  $version ](fg:color_fg bg:color_red)";
      };

      docker_context = {
        symbol = "";
        style = "bg:color_red";
        format = "[[ $symbol( $context) ](fg:color_fg bg:color_red)]($style)";
      };

    };
  };
}

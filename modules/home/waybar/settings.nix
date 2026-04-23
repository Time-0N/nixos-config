{ pkgs, vars, ... }:

let
  scripts = import ../../../scripts/waybar { inherit pkgs; };
in
{

  # ── Bar layout & modules ─────────────────────────────────────────────────
  programs.waybar.settings = [
    {
      layer = "top";
      position = "top";
      height = 16;
      margin-top = 10;
      margin-bottom = 0;
      margin-left = 0;
      margin-right = 0;
      spacing = 0;

      modules-left = [
        "custom/startmenu"
        "wireplumber#sink"
        "wireplumber#mic"
        "cpu"
        "memory"
      ];
      modules-center = [ "hyprland/workspaces" ];
      modules-right =
        (
          if (vars.enableLaptopMode or false) then
            [
              "battery"
              "power-profiles-daemon"
              "backlight"
            ]
          else
            [ ]
        )
        ++ [
          "idle_inhibitor"
          "bluetooth"
          "network"
          "tray"
          "clock"
        ];

      # ── Module definitions ──────────────────────────────────────────────

      bluetooth = {
        format = "";
        tooltip-format-connected = "{device_enumerate}";
        tooltip-format-enumerate-connected = "• {device_alias}";
        on-click = "blueman-manager";
      };

      network = {
        format = "";
        format-wifi = "{icon}";
        format-ethernet = "󰈀";
        format-disconnected = "Disconnected ⚠";
        format-icons = [
          "󰤯"
          "󰤟"
          "󰤢"
          "󰤥"
          "󰤨"
        ];
        tooltip-format = "󱘖 {ifname} via {gwaddr}";
        tooltip-format-wifi = "  {ifname} @ {essid}\nIP: {ipaddr}\nStrength: {signalStrength}%\nFreq: {frequency}MHz\nUp: {bandwidthUpBits} Down: {bandwidthDownBits}";
        tooltip-format-ethernet = " {ifname}\nIP: {ipaddr}\nUp: {bandwidthUpBits} Down: {bandwidthDownBits}";
        tooltip-format-disconnected = "Disconnected";
        on-click = "kitty --class gazelle-network gazelle";
        on-click-right = "kitty --class gazelle-network gazelle";
        interval = 1;
      };

      "wireplumber#sink" = {
        node-type = "Audio/Sink";
        format = " {volume}%";
        format-muted = "";
        on-click-right = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
        on-scroll-up = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+";
        on-scroll-down = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-";
      };

      "wireplumber#mic" = {
        node-type = "Audio/Source";
        format = " {volume}%";
        format-muted = "";
        on-click-right = "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle";
        on-scroll-up = "wpctl set-volume @DEFAULT_AUDIO_SOURCE@ 5%+";
        on-scroll-down = "wpctl set-volume @DEFAULT_AUDIO_SOURCE@ 5%-";
      };

      mpris = {
        format = "{status_icon} {title}";
        format-paused = "{status_icon} {title}";
        status-icons = {
          playing = "";
          paused = "";
          stopped = "";
        };
        title-len = 30;
        artist-len = 20;
        max-length = 100;
        tooltip-format = "Playing: {title} - {artist}";
        on-click = "playerctl play-pause";
        on-click-middle = "playerctl previous";
        on-click-right = "playerctl next";
      };

      tray = {
        icon-size = 20;
        spacing = 10;
        show-passive-items = true;
        reverse-direction = false;
        smooth-scrolling-threshold = 1.0;
      };

      "cpu" = {
        interval = 5;
        format = " {usage:2}%";
        tooltip = true;
      };

      "memory" = {
        interval = 5;
        format = " {}%";
        tooltip = true;
        on-click = "${vars.terminal} -e btop";
      };

      "hyprland/workspaces" = {
        format = "{name}";
        format-icons = {
          default = " ";
          active = " ";
          urgent = " ";
        };
        persistent-workspaces = {
          "*" = 1;
        };
        disable-scroll = true;
        all-outputs = true;
        show-special = true;
      };

      idle_inhibitor = {
        format = "{icon}";
        format-icons = {
          activated = "";
          deactivated = "";
        };
        tooltip-format-activated = "Idle inhibitor: ON";
        tooltip-format-deactivated = "Idle inhibitor: OFF";
      };

      clock = {
        format = "<span>  {:%H:%M %a}</span>";
        "tooltip-format" = "{calendar}";
        calendar = {
          mode = "month";
          "mode-mon-col" = 3;
          "on-scroll" = 1;
          "on-click-right" = "mode";
          format = {
            months = "<span color='#ffead3'><b>{}</b></span>";
            days = "<span color='#ecc6d9'><b>{}</b></span>";
            weeks = "<span color='#99ffdd'><b>{%W}</b></span>";
            weekdays = "<span color='#ffcc66'><b>{}</b></span>";
            today = "<span color='#ff6699'><b>{}</b></span>";
          };
        };
        actions = {
          "on-click-middle" = "mode";
          "on-click-right" = "shift_up";
          "on-click" = "shift_down";
        };
      };

      "custom/startmenu" = {
        tooltip = false;
        format = "";
        on-click = "wlogout";
        # exec = "rofi -show drun";
        #on-click = "sleep 0.1 && rofi-launcher";
        #on-click = "sleep 0.1 && nwg-drawer -mb 200 -mt 200 -mr 200 -ml 200";
      };

      battery = {
        interval = 5;
        format = "{icon} {capacity}%";
        format-charging = "󰂄 {capacity}%";
        format-plugged = "󰚥 {capacity}%";
        format-icons = [
          "󰁺"
          "󰁻"
          "󰁼"
          "󰁽"
          "󰁾"
          "󰁿"
          "󰂀"
          "󰂁"
          "󰂂"
          "󰁹"
        ];
        tooltip-format = "{timeTo}\nPower: {power:.1f}W";
        states = {
          warning = 30;
          critical = 15;
        };
      };

      backlight = {
        device = "intel_backlight";
        format = "{icon} {percent}%";
        signal = 8;
        format-icons = [
          "󰃞"
          "󰃟"
          "󰃠"
        ];
        on-scroll-up = "brightnessctl set 1%+";
        on-scroll-down = "brightnessctl set 1%-";
        tooltip = false;
      };

      "power-profiles-daemon" = {
        format = "{icon}";
        tooltip-format = "Power profile: {profile}\nDriver: {driver}";
        tooltip = true;
        format-icons = {
          default = "";
          performance = "";
          balanced = "";
          power-saver = "";
        };
      };
    }
  ];
}

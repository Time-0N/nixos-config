{ pkgs, ... }:

let
  scripts = import ../../scripts/waybar { inherit pkgs; };
in
{

  # ── Bar layout & modules ─────────────────────────────────────────────────
  programs.waybar.settings = [
    {
      layer = "top";
      height = 16;
      margin-top = 14;
      margin-bottom = 0;
      margin-left = 0;
      margin-right = 0;
      spacing = 0;

      modules-left = [
        "custom/os"
        "tray"
        "mpris"
      ];
      modules-center = [ "hyprland/workspaces" ];
      modules-right = [
        "idle_inhibitor"
        "bluetooth"
        "network"
        "wireplumber#sink"
        "wireplumber#mic"
        "clock"
        "custom/power"
      ];

      # ── Module definitions ──────────────────────────────────────────────

      bluetooth = {
        format = "";
        tooltip-format-connected = "{device_enumerate}";
        tooltip-format-enumerate-connected = "• {device_alias}";
        on-click = "blueman-manager";
      };

      network = {
        format = "{ifname}";
        format-wifi = "{icon}";
        format-ethernet = "󱘖";
        format-disconnected = "Disconnected ⚠";
        format-icons = [
          "󰤯"
          "󰤟"
          "󰤢"
          "󰤥"
          "󰤨"
        ];
        tooltip-format = "󱘖 {ifname} via {gwaddri}";
        tooltip-format-wifi = "  {ifname} @ {essid}\nIP: {ipaddr}\nStrength: {signalStrength}%\nFreq: {frequency}MHz\nUp: {bandwidthUpBits} Down: {bandwidthDownBits}";
        tooltip-format-ethernet = " {ifname}\nIP: {ipaddr}\nUp: {bandwidthUpBits} Down: {bandwidthDownBits}";
        tooltip-format-disconnected = "Disconnected";
        on-click = "nm-connection-editor";
        on-click-right = "nm-connection-editor";
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
        format = "{status_icon} {title} - {artist}";
        format-paused = "{status_icon} {title} - {artist}";
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

      "custom/os" = {
        exec = "${scripts.osLogo}/bin/waybar-os-logo";
        return-type = "json";
        format = "{}";
      };

      tray = {
        icon-size = 20;
        spacing = 10;
        show-passive-items = true;
        reverse-direction = false;
        smooth-scrolling-threshold = 1.0;
      };

      "hyprland/workspaces" = {
        format = "{icon}";
        format-icons = {
          default = "";
          active = "";
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
          activated = "󰌾";
          deactivated = "󰌵";
        };
        tooltip-format-activated = "Idle inhibitor: ON";
        tooltip-format-deactivated = "Idle inhibitor: OFF";
      };

      clock = {
        format = "  {:%H:%M %a}";
        format-alt = "  {:%d/%m/%Y  %H:%M:%S}";
        tooltip-format = "<tt><small>{calendar}</small></tt>";
        calendar = {
          mode = "month";
          mode-mon-col = 3;
          weeks-pos = "right";
          on-scroll = 1;
          on-click-right = "mode";
          format = {
            months = "<span color='#ffead3'><b>{}</b></span>";
            days = "<span color='#ecc6d9'><b>{}</b></span>";
            weeks = "<span color='#99ffdd'><b>W{}</b></span>";
            weekdays = "<span color='#ffcc66'><b>{}</b></span>";
            today = "<span color='#ff6699'><b><u>{}</u></b></span>";
          };
        };
        interval = 1;
      };

      "custom/power" = {
        format = "";
        on-click = "wlogout";
        tooltip = false;
      };
    }
  ];
}

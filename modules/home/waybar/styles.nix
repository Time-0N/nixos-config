{ ... }:

let
  colors = import ./colors.nix;
in
{
  programs.waybar.style = colors + ''
    /* ── Base ──────────────────────────────────────────────────────────────── */

    * {
      min-height: 0;
      font-family: "CodeNewRoman Nerd Font Propo";
      font-size: 16pt;
      font-weight: bold;
    }

    #cpu, #memory, #network, #tray, #wireplumber, #idle_inhibitor, #clock, #custom-startmenu, #bluetooth {
      padding: 0px 10px;
      margin: 5px 4px;
      background: alpha(@background, .5);
      border-radius: 10px;
      transition: all 0.3s cubic-bezier(0.25, 1, 0.5, 1);

      border-top: 1px solid alpha(white, 0.25);
      border-left: 1px solid alpha(white, 0.12);
      border-right: 1px solid alpha(white, 0.05);
      border-bottom: 1px solid alpha(white, 0.05);
    }

    tooltip {
      background: @background;
      border-radius: 7px;
      border: 2px solid @color4;
    }

    window#waybar {
      background: rgba(0,0,0,0);
    }

    /* ── Clock ──────────────────────────────────────────────────────────────── */
    #clock {
      margin-right: 10px;
      color: @color6;
    }
    #clock:hover { color: @color4; }

    /* ── Idle inhibitor ─────────────────────────────────────────────────────── */
    #idle_inhibitor {
      margin-right: 0px;
      border-right: 0px;
      border-radius: 10px 0px 0px 10px;
      color: @color6;
    }
    #idle_inhibitor:hover { color: @color4; }
    #idle_inhibitor.activated { color: @color2; }
    #idle_inhibitor.activated:hover { color: @color4; }

    /* ── Workspaces ─────────────────────────────────────────────────────────── */

    #workspaces {
      padding: 0px 10px;
      border-radius: 16px;
      background: alpha(@background, .5);
      color: @color6;

      border-top: 1px solid alpha(white, 0.25);
      border-left: 1px solid alpha(white, 0.12);
      border-right: 1px solid alpha(white, 0.05);
      border-bottom: 1px solid alpha(white, 0.05);
    }
    #workspaces button {
      margin: 6px;
      border-radius: 16px;
      color: alpha(@color5, .4);
      transition: all 0.3s cubic-bezier(0.25, 1, 0.5, 1);
    }
    #workspaces button:hover {
      border: solid transparent;
    }
    #workspaces button.active {
      background: @color6;
      color: @background;
      min-width: 40px;
    }
    #workspaces button.empty {
      border-radius: 16px;
      color: @second-background;
    }
    #workspaces button.empty:hover {
      margin: 5px;
      border-radius: 16px;
      border: solid transparent;
    }
    #workspaces button.empty.active {
      color: @color7;
    }

    /* ── Bluetooth ──────────────────────────────────────────────────────────── */
    #bluetooth {
      margin-right: 0px;
      margin-left: 0px;
      border-left: 0px;
      border-right: 0px;
      border-radius: 0px 0px 0px 0px;
      color: @color1;
    }
    #bluetooth.on, #bluetooth.connected  { color: @color2; }
    #bluetooth.off, #bluetooth.disabled  { color: @color0; }
    #bluetooth.on:hover, #bluetooth.off:hover,
    #bluetooth.connected:hover, #bluetooth.disabled:hover { color: @color4; }

    /* ── Network ────────────────────────────────────────────────────────────── */
    #network {
      margin-right: 0px;
      margin-left: 0px;
      border-left: 0px;
      border-radius: 0px 10px 10px 0px;
      color: @color6;
    }
    #network:hover { color: @color4; }
    #network.linked {
      color: @color7;
    }
    #network.disconnected,
    #network.disabled {
      color: @color1;
    }

    /* ── Tray ───────────────────────────────────────────────────────────────── */
    #tray {
    }

    /* ── CPU / Memory ─────────────────────────────────────────────────── */
    #cpu {
      color: @color3;
    }
    #memory {
      color: @color3;
    }
    #memory:hover  { color: @color4; }
    #cpu:hover { color: @color4; }

    #wireplumber.sink {
      color: @color1;
      border-radius: 10px 0px 0px 10px;
      margin-right: 0px;
      border-right: 0px;
      margin-left: 5px;
    }

    #wireplumber.mic {
      color: @color1;
      border-radius: 0px 10px 10px 0px;
      margin-left: 0px;
      border-left: 0px;
      margin-right: 5px;
    }
    #wireplumber:hover       { color: @color4; }
    #wireplumber.muted       { color: @color0; }
    #wireplumber.muted:hover { color: @color4; }

    /* ── MPRIS ──────────────────────────────────────────────────────────────── */
    #mpris { padding: 0px 5px; color: @color7; transition: all .3s ease; }
    #mpris:hover { color: @color4; }

    /* ── Cava ───────────────────────────────────────────────────────────────── */
    #custom-cava { padding: 0px 5px; color: @color3; transition: all .3s ease; }
    #custom-cava:hover { color: @color4; }

    /* ── Startmenu ──────────────────────────────────────────────────────────────── */
    #custom-startmenu {
      margin-left: 10px;
      color: #7ebae4;
    }
    #custom-startmenu:hover { color: @color4; }

  '';
}

{ ... }:

let
  colors = import ./colors.nix;
in
{
  programs.waybar.style = colors + ''
    /* ── Base ──────────────────────────────────────────────────────────────── */
    * {
      font-size:   15px;
      font-family: "CodeNewRoman Nerd Font Propo";
    }

    window#waybar { all: unset; }

    /* ── Bar sections ───────────────────────────────────────────────────────── */
    .modules-left {
      padding:       7px;
      margin:        10px 0px 5px 10px;
      border-radius: 10px;
      background:    alpha(@background, .6);
      box-shadow:    0px 0px 2px rgba(0,0,0,.6);
    }
    .modules-center {
      padding:       7px;
      margin:        10px 0px 5px 10px;
      border-radius: 10px;
      background:    alpha(@background, .6);
      box-shadow:    0px 0px 2px rgba(0,0,0,.6);
    }
    .modules-right {
      padding:       7px;
      margin:        10px 10px 5px 0px;
      border-radius: 10px;
      background:    alpha(@background, .6);
      box-shadow:    0px 0px 2px rgba(0,0,0,.6);
    }

    .tooltip {
      background: @background;
      color:      @color0;
    }

    /* ── Clock ──────────────────────────────────────────────────────────────── */
    #clock { padding: 0px 5px; color: @color6; transition: all .3s ease; }
    #clock:hover { color: @color4; }

    /* ── Idle inhibitor ─────────────────────────────────────────────────────── */
    #idle_inhibitor { padding: 0px 5px; color: @color5; transition: all .3s ease; }
    #idle_inhibitor:hover           { color: @color4; }
    #idle_inhibitor.activated       { color: @color2; }
    #idle_inhibitor.activated:hover { color: @color4; }

    /* ── Workspaces ─────────────────────────────────────────────────────────── */
    #workspaces { padding: 0px 5px; }
    #workspaces button {
      all:        unset;
      padding:    0px 5px;
      color:      alpha(@color5, .4);
      transition: all .2s ease;
    }
    #workspaces button:hover {
      color:       @second-background;
      text-shadow: 0px 0px 1.5px rgba(0,0,0,.5);
      transition:  all 1s ease;
    }
    #workspaces button.active {
      color:       @color6;
      text-shadow: 0px 0px 2px rgba(0,0,0,.5);
    }
    #workspaces button.empty {
      color:       @second-background;
      text-shadow: 0px 0px 1.5px rgba(0,0,0,.2);
    }
    #workspaces button.empty:hover {
      text-shadow: 0px 0px 1.5px rgba(0,0,0,.5);
      transition:  all 1s ease;
    }
    #workspaces button.empty.active {
      color:       @color6;
      text-shadow: 0px 0px 2px rgba(0,0,0,.5);
    }

    /* ── Bluetooth ──────────────────────────────────────────────────────────── */
    #bluetooth { padding: 0px 5px; color: @color1; transition: all .3s ease; }
    #bluetooth.on, #bluetooth.connected  { color: @color2; }
    #bluetooth.off, #bluetooth.disabled  { color: @color0; }
    #bluetooth.on:hover, #bluetooth.off:hover,
    #bluetooth.connected:hover, #bluetooth.disabled:hover { color: @color4; }

    /* ── Network ────────────────────────────────────────────────────────────── */
    #network { padding: 0px 5px; color: @color6; transition: all .3s ease; }
    #network:hover { color: @color4; }

    /* ── Tray ───────────────────────────────────────────────────────────────── */
    #tray, #tray menu *, #tray menu separator {
      padding: 0px 5px; transition: all .3s ease;
    }

    /* ── CPU / Memory / GPU ─────────────────────────────────────────────────── */
    #cpu    { padding: 0px 5px; color: @color3; transition: all .3s ease; }
    #memory { padding: 0px 5px; color: @color7; transition: all .3s ease; }
    #memory:hover  { color: @color4; }
    #custom-gpu    { padding: 0px 5px; color: @color4; transition: all .3s ease; }

    /* ── Wireplumber ────────────────────────────────────────────────────────── */
    #wireplumber { padding: 0px 5px; color: @color1; transition: all .3s ease; }
    #wireplumber:hover       { color: @color4; }
    #wireplumber.muted       { color: @color0; }
    #wireplumber.muted:hover { color: @color4; }

    /* ── MPRIS ──────────────────────────────────────────────────────────────── */
    #mpris { padding: 0px 5px; color: @color7; transition: all .3s ease; }
    #mpris:hover { color: @color4; }

    /* ── Cava ───────────────────────────────────────────────────────────────── */
    #custom-cava { padding: 0px 5px; color: @color3; transition: all .3s ease; }
    #custom-cava:hover { color: @color4; }

    /* ── Power ──────────────────────────────────────────────────────────────── */
    #custom-power { padding: 0px 5px; color: @color5; transition: all .3s ease; }
    #custom-power:hover { color: @color0; }

    /* ── OS logo ────────────────────────────────────────────────────────────── */
    #custom-os                { padding: 0px 5px; }
    #custom-os.os-arch        { color: #1793d1; }
    #custom-os.os-ubuntu      { color: #e95420; }
    #custom-os.os-debian      { color: #d70751; }
    #custom-os.os-fedora      { color: #51a2da; }
    #custom-os.os-nixos       { color: #7ebae4; }
    #custom-os.os-opensuse    { color: #73ba25; }
    #custom-os.os-manjaro     { color: #35bf5c; }
    #custom-os.os-gentoo      { color: #54487a; }
    #custom-os.os-void        { color: #478061; }
    #custom-os.os-pop_os      { color: #48b9c7; }
    #custom-os.os-elementary  { color: #64baff; }
    #custom-os.os-endeavouros { color: #7F3FBF; }
    #custom-os.os-linux       { color: #b4c8be; }

    /* ── Notifications ──────────────────────────────────────────────────────── */
    #custom-notification { padding: 0px 5px; color: @color7; transition: all .3s ease; }
  '';
}

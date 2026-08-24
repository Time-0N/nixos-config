{ lib, ... }:
{
  imports = [
    ./animations.nix
    ./autostart.nix
    ./decorations.nix
    ./environment.nix
    ./general.nix
    ./hypridle.nix
    ./hyprlock.nix
    ./lockscreen.nix
    ./input.nix
    ./keybinds.nix
    ./windowrules.nix
    ./wallpaper-slideshow.nix
    ./xwayland-primary.nix
  ];

  wayland.windowManager.hyprland = {
    systemd.enable = false;
    enable = true;
    configType = "lua";

    # Replaces the old `source = ~/.config/hypr/monitors.conf`.
    #
    # monitors.lua is owned by the shell's settings panel (qml/bar/settings),
    # which rewrites it whole on every Apply. Home Manager appends extraConfig
    # last, after every hl.*() call it generates, so anything loaded here wins
    # over monitors declared in Nix.
    #
    # nwg-displays used to own this and wrote monitors.conf alongside for its
    # own read-back. That second file is no longer seeded: two writers for one
    # setting is how they end up disagreeing. nwg-displays still runs, but it
    # and the panel will now overwrite each other rather than sharing state —
    # pick one.
    #
    # To move monitors into Nix instead: drop this block and the activation
    # below, then add `settings.monitor = [ { output = "DP-1"; ... } ];` —
    # hl.monitor() is emitted once per list element.
    extraConfig = ''
      local hypr_config_dir = (os.getenv("XDG_CONFIG_HOME") or (os.getenv("HOME") .. "/.config")) .. "/hypr"

      -- dofile rather than require. `require("monitors")` does in fact work
      -- here, and the reason once given for avoiding it was wrong: Hyprland
      -- builds a *fresh* Lua state for every `hyprctl reload`, so
      -- package.loaded is empty each time and require re-reads the file. That
      -- was measured rather than assumed — a global and a package.loaded entry
      -- planted through `hyprctl eval` both survive a second eval and are both
      -- gone after a reload, and a test module required twice in one state
      -- executes once but executes again after a reload. The config dir is
      -- already on package.path (Hyprland puts it there), so require needs no
      -- path entry either.
      --
      -- It stays dofile because it is unconditional rather than
      -- conditionally-correct. require's correctness here rests on the state
      -- being new, which is a property of the reload path and not of this Lua
      -- environment: `hyprctl eval` shares one long-lived state across calls,
      -- as the same measurement showed. Anything that ever re-runs this config
      -- in a state that has already seen it — an eval, a future in-session
      -- reload — gets the layout from session start with no way to tell. dofile
      -- re-executes because that is all it does, and it names the file instead
      -- of asking a search path to find it.
      --
      -- Neither choice affects VRR. A `vrr` in a monitor rule is read when the
      -- output comes up and not afterwards, so it takes on the next Hyprland
      -- start whichever way this file is loaded — also measured: vrr = 1 in
      -- monitors.lua followed by a reload leaves DRM's VRR_ENABLED at 0, and so
      -- does pushing the same rule through `hyprctl eval`.
      --
      -- pcall so a missing or malformed monitors.lua leaves a usable display
      -- rather than no output at all.
      local ok, err = pcall(dofile, hypr_config_dir .. "/monitors.lua")
      if not ok then
        hl.monitor({
          output = "",
          mode = "preferred",
          position = "auto",
          scale = "auto",
        })
        hl.notification.create({
          text = "monitors.lua not loaded, using preferred mode: " .. tostring(err),
          timeout = 5000,
        })
      end
    '';
  };

  xdg.configFile."hypr/xdph.conf".text = ''
    screencopy {
      allow_token_by_default = true
    }
  '';

  # Seed monitors.lua on first run so the dofile above has something to read.
  # Never overwritten: past first run the settings panel owns this file.
  home.activation.createMonitorsConf = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    HYPR_DIR="$HOME/.config/hypr"
    mkdir -p "$HYPR_DIR"

    if [ ! -f "$HYPR_DIR/monitors.lua" ]; then
      cat > "$HYPR_DIR/monitors.lua" << 'EOF'
    -- Owned by the quickshell settings panel — do not edit manually
    -- Open the bar's settings panel to configure your monitors
    hl.monitor({ output = "", mode = "preferred", position = "auto", scale = "auto" })
    EOF
    fi
  '';
}

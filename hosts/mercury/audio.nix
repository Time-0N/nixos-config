{
  lib,
  pkgs,
  vars,
  ...
}:

let
  # Plugins arrive through environment.systemPackages, and no plugin host looks
  # there on its own - Carla and Ardour scan /usr/lib/lv2 and ~/.lv2, find
  # nothing on NixOS, and come up with an empty rack. The paths are spelled out
  # instead of built from $HOME so they also hold in the graphical session,
  # where nothing expands shell variables.
  pluginPath =
    format:
    lib.makeSearchPath format [
      "/run/current-system/sw/lib"
      "/etc/profiles/per-user/${vars.username}/lib"
      "/home/${vars.username}/.nix-profile/lib"
    ]
    + ":/home/${vars.username}/.${format}";

  # The desktop sits at a 1024 sample quantum, which is the right trade for
  # everything except playing an instrument - at 48 kHz that is roughly a fifth
  # of a second round trip and you cannot play in time through it. Dropping the
  # quantum globally would make the whole machine wake up far more often for
  # buffers nothing else needs, so this drops it only while Carla is open and
  # puts it back on the way out.
  #
  # The CPU profile is asked for the same way. modules/core/power-profile.nix
  # leaves power-profiles-daemon in charge of the governor, so setting
  # powerManagement.cpuFreqGovernor here would fight it - asking the daemon
  # reaches the same place without the argument, and the bar keeps agreeing
  # with reality.
  #
  # Ardour, Reaper and Carla are all built against jack2, so their RUNPATH
  # finds the real libjack, which then looks for a jackd that is not running
  # and never will be. pw-jack puts PipeWire's replacement libjack ahead of it
  # on LD_LIBRARY_PATH for the one process. services.pipewire.jack.enable does
  # the same thing session wide, but only from the next login onward - doing it
  # here as well means the rig does not care when the machine last rebooted.
  #
  # The host is an argument rather than baked in, so swapping one out is not a
  # rebuild. Note the binary is ardour9, not ardour; nixpkgs versions it.
  #
  #   guitar-rig                          Ardour
  #   guitar-rig reaper
  #   guitar-rig ardour9 ~/music/puppets  open a session directly
  #   GUITAR_QUANTUM=64 guitar-rig        if 128 is still not tight enough
  guitar-rig = pkgs.writeShellApplication {
    name = "guitar-rig";

    runtimeInputs = with pkgs; [
      ardour # The default host; anything else is picked up from PATH
      pipewire # pw-metadata
      pipewire.jack # pw-jack, which lives in a separate output
      power-profiles-daemon
    ];

    text = ''
      if [ "$#" -eq 0 ]; then
        set -- ardour9
      fi

      quantum="''${GUITAR_QUANTUM:-128}"
      previous=""

      restore() {
        pw-metadata -n settings 0 clock.force-quantum 0 > /dev/null
        if [ -n "$previous" ]; then
          powerprofilesctl set "$previous" || true
        fi
      }
      trap restore EXIT

      if previous="$(powerprofilesctl get 2> /dev/null)"; then
        powerprofilesctl set performance || true
      fi

      pw-metadata -n settings 0 clock.force-quantum "$quantum" > /dev/null
      echo "Rig up: $quantum samples at 48 kHz, host $1."

      pw-jack "$@"
    '';
  };
in
{
  # ── PipeWire and the M4 ────────────────────────────────────────
  services.pipewire = {
    jack.enable = true;

    extraConfig.pipewire."99-resample" = {
      "stream.properties"."resample.quality" = 10;
    };

    wireplumber.extraConfig."51-motu-m4" = {
      "monitor.alsa.rules" = [
        {
          matches = [ { "device.name" = "~alsa_card.*MOTU.*"; } ];
          actions.update-props = {
            "api.alsa.use-ucm" = false;
            "device.profile" = "pro-audio";
          };
        }
        {
          matches = [ { "node.name" = "~alsa_input\\..*MOTU.*"; } ];
          actions.update-props = {
            "node.description" = "M4 Guitar In";
            "api.alsa.headroom" = 128;
            "session.suspend-timeout-seconds" = 0;
            "priority.session" = 100;
          };
        }
        {
          matches = [ { "node.name" = "~alsa_output\\..*MOTU.*"; } ];
          actions.update-props = {
            "priority.session" = 100;
            "priority.driver" = 100;
          };
        }
      ];
    };
  };

  # ── Real-time scheduling ───────────────────────────────────────
  # rtkit is already on in modules/core/audio.nix, but it only grants priority
  # to processes that are permitted to ask for it. A JACK graph also needs its
  # buffers locked into RAM, because a page fault in the middle of a 2.7 ms
  # period is an xrun. Both are limits on the audio group, so the user has to
  # actually be in that group for either to apply.
  users.users.${vars.username}.extraGroups = [ "audio" ];

  security.pam.loginLimits = [
    {
      domain = "@audio";
      item = "memlock";
      type = "-";
      value = "unlimited";
    }
    {
      domain = "@audio";
      item = "rtprio";
      type = "-";
      value = "99";
    }
  ];

  # ── Kernel ─────────────────────────────────────────────────────
  # Merged into the quiet-boot list in modules/core/boot.nix.
  boot.kernelParams = [
    # Interrupt handlers become schedulable threads, so a busy USB or GPU
    # interrupt can be preempted by the audio thread rather than stalling it.
    "threadirqs"

    # Voluntary preemption, the default, is tuned for throughput and hands the
    # CPU over too rarely to hold a 128 sample period without dropouts.
    "preempt=full"

    # Otherwise the M4 is allowed to autosuspend on an idle bus and comes back
    # with a click, or does not come back at all until it is replugged.
    "usbcore.autosuspend=-1"
  ];

  # ── Plugin search paths ────────────────────────────────────────
  # sessionVariables rather than variables: these have to reach Carla when it
  # is launched from fuzzel or the bar, not only from a shell that sourced
  # /etc/profile.
  environment.sessionVariables = {
    LV2_PATH = pluginPath "lv2";
    VST3_PATH = pluginPath "vst3";
    CLAP_PATH = pluginPath "clap";
  };

  # ── The rig ────────────────────────────────────────────────────
  # Chain in Carla: M4 in -> tuner -> gate -> boost -> amp -> cabinet IR ->
  # reverb -> out. The cabinet is not optional - a neural model covers the
  # preamp and power amp only, and without an IR after it the result is thin
  # and fizzy no matter which capture is loaded. Captures and IRs come from
  # tone3000.com, not from nixpkgs; drop them anywhere and point the plugin at
  # the file.
  environment.systemPackages = [
    guitar-rig
  ]
  ++ (with pkgs; [
    ardour # Reference LV2 host; the one to trust when a plugin misbehaves
    reaper # Unfree, 60 day evaluation. allowUnfree is on in core/programs.nix
    qpwgraph # PipeWire never auto-connects the M4; wire it up here

    neural-amp-modeler-lv2 # Loads .nam captures; no GUI, the host draws it

    lsp-plugins # Cabinet IR loader, gate, EQ, and the latency meter
    x42-plugins # Tuner
    gxplugins-lv2 # The guitarix pedals, without the guitarix window
    chow-centaur # Klon-style boost, to tighten the low end before the amp
    dragonfly-reverb
  ]);
}

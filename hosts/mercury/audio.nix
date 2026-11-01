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

  # ── How the M4 presents itself ─────────────────────────────────
  # The pro-audio profile hands the card over untouched: four capture and four
  # playback channels, no mixer, no routing, which is exactly what a DAW wants.
  # The price is that PipeWire has no names for those channels and labels them
  # AUX0 to AUX3, so everything downstream - pavucontrol, Discord, OBS, the bar
  # - sees one anonymous four channel lump. An app that asks for "the
  # microphone" is handed that lump and takes the first two channels it finds,
  # which is why a browser tab ends up listening to both front inputs at once.
  #
  # The fix is not to drop pro-audio - that would cost the direct, unmixed path
  # the guitar rig needs. Instead the raw device keeps its four channels for
  # Carla and Ardour, and a loopback per useful grouping publishes those
  # channels under real names. Ordinary apps pick one of those and get one
  # input, always the same one.
  #
  # AUX0..AUX3 are the channels in panel order:
  #
  #   capture   AUX0  input 1, front combo jack (mic / instrument / line)
  #             AUX1  input 2, front combo jack
  #             AUX2  input 3, rear TRS, line level
  #             AUX3  input 4, rear TRS, line level
  #   playback  AUX0  monitor out L  }  rear TRS pair
  #             AUX1  monitor out R  }
  #             AUX2  line out 3     }  rear TRS pair
  #             AUX3  line out 4     }
  #
  # Which pair the front panel phones jack follows is the M4's own business and
  # not visible over USB - the card exposes no mixer controls at all - so check
  # by ear rather than trusting a label here.

  # The names the monitor rules below pin on the raw device. The defaults carry
  # the unit's serial number (alsa_input.usb-MOTU_M4_M4MA07D6TY-00.pro-input-0)
  # and every loopback has to point at them, so they are renamed to something
  # that survives a replacement M4. WirePlumber applies monitor rules before it
  # creates the node, so these are the names the rest of the graph ever sees.
  rawSource = "alsa_input.motu-m4";
  rawSink = "alsa_output.motu-m4";

  # One loopback, with its device facing side pinned to a fixed set of the M4's
  # channels and its desktop facing side presented as an ordinary mono or
  # stereo device. This mirrors what WirePlumber itself builds for UCM cards
  # that declare split PCMs - same module, same flags - since the M4 declares
  # no UCM at all and so never qualifies for the built-in version.
  #
  # Direction decides which half is which: a source captures from the card and
  # publishes the result, a sink is written to and plays out to the card.
  m4Node =
    {
      id,
      description,
      class,
      channels,
      position,
      priority,
    }:
    let
      isSource = class == "Audio/Source";

      # The half that touches the card.
      #
      # stream.dont-remix is what makes this exact rather than approximate:
      # without it PipeWire would cheerfully fold all four channels into the
      # two it was asked for, which is the behaviour being fixed.
      #
      # The Internal media class keeps this plumbing out of the recording and
      # playback tabs of every mixer - nobody started it and nobody can move
      # it, so listing it only invites someone to try.
      #
      # node.dont-fallback matters more than it looks. Without it an absent M4
      # sends these streams hunting for any other device that will take them,
      # and "MOTU M4 Input 2" quietly becomes whatever else has a microphone.
      # node.passive keeps the links from counting as users of the card, so an
      # idle loopback cannot hold the graph awake by itself.
      deviceSide = {
        "node.name" = "motu_m4_link.${id}";
        "media.class" = if isSource then "Stream/Input/Audio/Internal" else "Stream/Output/Audio/Internal";
        "audio.channels" = builtins.length channels;
        "audio.position" = channels;
        "stream.dont-remix" = true;
        "target.object" = if isSource then rawSource else rawSink;
        "node.passive" = true;
        "node.dont-fallback" = true;
        "node.linger" = true;
        "state.restore-props" = false;
      };

      # The half the desktop sees. node.virtual is false because this is a real
      # jack on a real box and should be offered like one - WirePlumber says the
      # same thing about its own split nodes.
      desktopSide = {
        "node.name" = "motu_m4.${id}";
        "node.description" = description;
        "media.class" = class;
        "audio.channels" = builtins.length position;
        "audio.position" = position;
        "node.virtual" = false;
        "priority.session" = priority;
      };
    in
    {
      name = "libpipewire-module-loopback";
      args = {
        "node.description" = description;
      }
      // (
        if isSource then
          {
            "capture.props" = deviceSide;
            "playback.props" = desktopSide;
          }
        else
          {
            "capture.props" = desktopSide;
            "playback.props" = deviceSide;
          }
      );
    };

  # Session priorities decide what an app gets when it does not ask for
  # anything in particular. Input 2 wins among the sources because that is the
  # jack the microphone is in - an app that just wants "a microphone" has to
  # land on a channel that something is plugged into, or it looks broken.
  # Moving the mic to input 1 means swapping these two numbers. The sinks all
  # sit below the FiiO K7, which reports 1109 and stays the default output.
  #
  # A device picked by hand in pavucontrol is remembered by WirePlumber and
  # beats every number here - `wpctl status` prints those under "Default
  # Configured Devices" if a choice ever needs undoing.
  #
  # Dropping a line removes that node; adding one needs no more than a
  # different pair of channels. The guitar does not appear here on purpose,
  # since it goes through Carla on the raw device rather than through the
  # desktop.
  m4Nodes = map m4Node [
    {
      id = "in1";
      description = "MOTU M4 Input 1";
      class = "Audio/Source";
      channels = [ "AUX0" ];
      position = [ "MONO" ];
      priority = 1900;
    }
    {
      id = "in2";
      description = "MOTU M4 Input 2";
      class = "Audio/Source";
      channels = [ "AUX1" ];
      position = [ "MONO" ];
      priority = 2000;
    }
    {
      id = "in12";
      description = "MOTU M4 Inputs 1+2";
      class = "Audio/Source";
      channels = [
        "AUX0"
        "AUX1"
      ];
      position = [
        "FL"
        "FR"
      ];
      priority = 1800;
    }
    {
      id = "in34";
      description = "MOTU M4 Inputs 3/4";
      class = "Audio/Source";
      channels = [
        "AUX2"
        "AUX3"
      ];
      position = [
        "FL"
        "FR"
      ];
      priority = 1700;
    }
    {
      id = "monitor";
      description = "MOTU M4 Monitor Out 1/2";
      class = "Audio/Sink";
      channels = [
        "AUX0"
        "AUX1"
      ];
      position = [
        "FL"
        "FR"
      ];
      priority = 900;
    }
    {
      id = "line34";
      description = "MOTU M4 Line Out 3/4";
      class = "Audio/Sink";
      channels = [
        "AUX2"
        "AUX3"
      ];
      position = [
        "FL"
        "FR"
      ];
      priority = 800;
    }
  ];

  # The monitor rules that describe the card itself. These are bound here
  # rather than written straight into the config below so that the restart
  # triggers can hash them too - a change to a rule has to reach WirePlumber,
  # and before this it did not.
  m4MonitorRules = [
    {
      matches = [ { "device.name" = "~alsa_card.*MOTU.*"; } ];
      actions.update-props = {
        "api.alsa.use-ucm" = false;
        "device.profile" = "pro-audio";

        # "M Series" is what the card reports and it is the name of a
        # product line, not of this box.
        "device.description" = "MOTU M4";
        "device.nick" = "MOTU M4";
      };
    }

    # Matching happens against the names the monitor worked out, so these
    # patterns describe the device as it arrives and the actions rename it
    # on the way through.
    {
      matches = [ { "node.name" = "~alsa_input\\..*MOTU.*"; } ];
      actions.update-props = {
        "node.name" = rawSource;
        "node.description" = "MOTU M4 (all 4 inputs)";
        "node.nick" = "MOTU M4";

        # The one line that makes the inputs audible. The pro-audio
        # profile also sets api.alsa.disable-tsched, which asks PipeWire to
        # wake on the card's own period interrupts rather than on its
        # timer, and the M4 never drives that loop: ALSA reports the
        # capture stream RUNNING while appl_ptr sits at 0, pw-top shows the
        # node at quantum 0 and rate 0, and every reader - a loopback,
        # Discord, pw-record - gets a stream that opens, claims to be
        # streaming and then delivers no frames at all. Nothing downstream
        # can fix that, which is why the inputs listed correctly while a
        # mic test still read silence. Timer-based scheduling is what the
        # rest of the machine runs on and what this same card gets under
        # the non-pro profiles, where capture works, so it goes back on.
        "api.alsa.disable-tsched" = false;

        "api.alsa.headroom" = 128;
        "session.suspend-timeout-seconds" = 0;

        # Deliberately the lowest priority in the graph. The four channel
        # node is for Carla and Ardour, which ask for it by name; nothing
        # should land here by default, which is what used to put a Discord
        # call on inputs 1 and 2 at the same time.
        "priority.session" = 1;
      };
    }
    {
      matches = [ { "node.name" = "~alsa_output\\..*MOTU.*"; } ];
      actions.update-props = {
        "node.name" = rawSink;
        "node.description" = "MOTU M4 (all 4 outputs)";
        "node.nick" = "MOTU M4";

        # Capture and playback share one driver group (node.group =
        # pro-audio-3) and so have to agree about how they are woken.
        "api.alsa.disable-tsched" = false;

        "priority.session" = 1;
        "priority.driver" = 100;
      };
    }
  ];

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

    # The virtual nodes described above. These are daemon modules rather than
    # WirePlumber rules, so they exist for as long as PipeWire does; unplugging
    # the M4 leaves them listed but silent until it is back.
    #
    # context.modules is read once, when the daemon starts. A drop-in appends
    # to it - arrays merge that way, unlike the dictionaries elsewhere in this
    # file - but appending to a file changes nothing for a process that has
    # already read it, and nixos-rebuild does not restart the audio stack. See
    # the restartTriggers below, which is what makes a switch take effect.
    extraConfig.pipewire."61-motu-m4-nodes"."context.modules" = m4Nodes;

    wireplumber.extraConfig."51-motu-m4"."monitor.alsa.rules" = m4MonitorRules;
  };

  # ── Applying a change to any of the above ──────────────────────
  # NixOS leaves the audio stack alone across a rebuild on purpose, since
  # restarting it drops every stream the machine is playing. The cost is that a
  # switch appears to do nothing here: WirePlumber rules land whenever it next
  # happens to start, while the loopbacks above need the daemon itself to come
  # back, so the two halves of this file can silently disagree for hours.
  #
  # Tying the units to the node definitions trades that silence for a known
  # interruption - audio cuts out for a second during a switch that touched
  # this file, and nothing else. pipewire-pulse and wireplumber are listed too
  # because both reconnect to the daemon and need to follow it round.
  systemd.user.services =
    let
      # Both halves of the file, so that editing a monitor rule restarts
      # WirePlumber as well. The loopback definitions alone used to be the
      # whole trigger, which meant a changed rule reached /etc and nowhere
      # else, and the card kept whatever props it was created with until the
      # next login.
      trigger = builtins.toJSON {
        nodes = m4Nodes;
        rules = m4MonitorRules;
      };
    in
    {
      pipewire.restartTriggers = [ trigger ];
      pipewire-pulse.restartTriggers = [ trigger ];
      wireplumber.restartTriggers = [ trigger ];
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
  # reverb -> out.
  #
  # "M4 in" is a port on the raw four channel node, which appears in qpwgraph
  # and Carla as MOTU M4 and carries capture_AUX0 to capture_AUX3 - a guitar in
  # front input 1 is capture_AUX0, input 2 is capture_AUX1. Patch from there,
  # not from one of the named desktop inputs: those go through a loopback, and
  # borrowing one would add its buffer to the round trip for no reason. Nothing
  # auto-connects either way, which is why qpwgraph is installed.
  #
  # The cabinet is not optional - a neural model covers the
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

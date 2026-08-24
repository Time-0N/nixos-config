import Quickshell
import Quickshell.Io
import Quickshell.Services.UPower
import QtQuick

// The battery and the power profile: what the machine reports, and whether it
// reports it at all.
//
// Non-visual, and instantiated once at ShellRoot level so every bar shows the
// same charge and so the capability probe runs once rather than once per
// output.
//
// Both halves are optional and are asked about separately. A desktop has
// neither. This machine has power profiles and no battery. A laptop with no
// performance platform driver has a battery and two profiles rather than
// three. Nothing here assumes that having one means having the other.
Scope {
    id: root

    // ── Battery ────────────────────────────────────────────────────────
    // UPower's synthetic aggregate rather than a device picked out of
    // UPower.devices: a laptop with two batteries has two devices and one
    // charge level, and this is the device that reports it. It is also handed
    // out before UPower has answered — `ready` is documented as false for this
    // one device specifically, to avoid returning null — so everything below
    // it goes through `?.` and has a fallback.
    readonly property var battery: UPower.displayDevice

    // The gate the settings toggle and the island both read.
    //
    // `isLaptopBattery` is UPower's own `type == Battery && powerSupply`, and
    // the daemon sets both on the aggregate only once it has found a real
    // battery to aggregate: on a desktop the type stays Unknown, and with no
    // UPower on the bus nothing is ever set at all — which is the case on
    // mercury, where the service is not even activatable. `isPresent` is the
    // hot-removable case on top of that: the bay is there and empty.
    readonly property bool batteryAvailable: (root.battery?.isLaptopBattery ?? false) && (root.battery?.isPresent ?? false)

    // UPower reports Percentage as 0–100 and Quickshell divides it by 100 on
    // the way through, so this is the one place that multiplies it back.
    readonly property int percent: Math.round((root.battery?.percentage ?? 0) * 100)

    readonly property int state: root.battery?.state ?? UPowerDeviceState.Unknown
    readonly property bool charging: root.state === UPowerDeviceState.Charging || root.state === UPowerDeviceState.PendingCharge
    readonly property bool full: root.state === UPowerDeviceState.FullyCharged

    // waybar's own thresholds, carried over: `states = { warning = 30;
    // critical = 15; }`. Only while discharging — a battery climbing through
    // 12% on the charger is not a warning, it is the fix in progress.
    readonly property bool low: !root.charging && !root.full && root.percent <= 30
    readonly property bool critical: !root.charging && !root.full && root.percent <= 15

    // The ten-step ramp waybar's `format-icons` used, in the same order.
    readonly property var levelGlyphs: ["󰁺", "󰁻", "󰁼", "󰁽", "󰁾", "󰁿", "󰂀", "󰂁", "󰂂", "󰁹"]

    // Charging and full get a picture of their own, exactly as the waybar
    // config did — `format-charging` and `format-plugged`. The level ramp
    // underneath them is only meaningful while the number is falling.
    readonly property string batteryGlyph: {
        if (root.charging)
            return "󰂄";  // md-battery_charging
        if (root.full)
            return "󰚥";  // md-power_plug
        // 0-9 rather than a rounded tenth: 100% must not index past the end,
        // and anything above 0 must not read as empty.
        const step = Math.max(0, Math.min(9, Math.floor(root.percent / 10)));
        return root.levelGlyphs[step];
    }

    // ── Power profiles ─────────────────────────────────────────────────
    // The three ppd knows about, in increasing order of consequence, each with
    // the glyph the waybar module used for it. This is the full set rather
    // than what the machine has; `profiles` below is the intersection.
    readonly property var knownProfiles: [
        {
            id: "power-saver",
            value: PowerProfile.PowerSaver,
            label: "Saver",
            glyph: ""  // fa-leaf
        },
        {
            id: "balanced",
            value: PowerProfile.Balanced,
            label: "Balanced",
            glyph: ""  // fa-balance-scale
        },
        {
            id: "performance",
            value: PowerProfile.Performance,
            label: "Performance",
            glyph: ""  // fa-bolt
        }
    ]

    // What profiles.sh answered, by ppd's own names. Empty until it has run,
    // and empty forever on a machine with no daemon.
    property var profileNames: []

    // What this machine can actually be switched to.
    //
    // Performance carries a second condition, and it is not belt and braces:
    // Quickshell refuses to write that profile unless `hasPerformanceProfile`
    // is true, so offering it before that has arrived would be offering a
    // click that silently does nothing. The property is filled from an async
    // DBus reply about a second after start — this is a binding, so the option
    // appears when the answer does.
    readonly property var profiles: root.knownProfiles.filter(profile => root.profileNames.indexOf(profile.id) !== -1 && (profile.value !== PowerProfile.Performance || PowerProfiles.hasPerformanceProfile))

    readonly property bool profilesAvailable: root.profiles.length > 0

    // Falls back to the first available rather than to null, so a daemon
    // sitting in a profile this machine somehow does not list still leaves the
    // island something to draw.
    readonly property var currentProfile: root.profiles.find(profile => profile.value === PowerProfiles.profile) ?? root.profiles[0] ?? null

    // Clicking steps along the list rather than opening a menu. There are two
    // or three of these and they are ordered, which is a switch rather than a
    // choice — the same reasoning that makes the audio pill's scroll a step
    // and not a slider.
    function cycle(direction) {
        if (root.profiles.length === 0)
            return;
        const at = root.profiles.findIndex(profile => profile.value === PowerProfiles.profile);
        // A profile that is not in the list counts as before the start, so the
        // first step lands on index 0 rather than skipping it.
        const next = (Math.max(0, at) + direction + root.profiles.length) % root.profiles.length;
        PowerProfiles.profile = root.profiles[next].value;
    }

    // ── Capability probe ───────────────────────────────────────────────
    // Same idiom as the VRR probe and the network script: resolved against
    // this file, so it works from the store and from a working tree alike.
    readonly property string scriptPath: Qt.resolvedUrl("profiles.sh").toString().replace("file://", "")

    function refresh() {
        profileProbe.running = true;
    }

    Process {
        id: profileProbe

        command: ["bash", root.scriptPath]
        // ppd is a system service that is either there or not; this is not
        // something to poll for. It runs once at start, and again each time
        // the settings panel opens — which is the moment the answer is about
        // to be shown rather than merely held.
        running: true

        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    root.profileNames = JSON.parse(this.text);
                } catch (error) {
                    // A shell that cannot answer is a machine with no
                    // profiles, which is the same outcome as the script's own
                    // `[]` fallback. Unlike the VRR probe, an unknown here
                    // hides the control rather than leaving it live: a switch
                    // that writes nowhere is worse than no switch.
                    root.profileNames = [];
                }
            }
        }
    }
}

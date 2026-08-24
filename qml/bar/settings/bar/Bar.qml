import Quickshell
import Quickshell.Io
import QtQuick

// The bar's own settings. Currently one, and it is how big everything on the
// bar is drawn.
//
// Unlike the wallpaper's config there is nothing outside the shell reading
// this file — no unit to restart, no state file to read back. `Theme.zoom` is
// bound straight to `zoom` below, and every metric in ../../theme/Theme.qml is
// a base value times that, so a change is on screen the moment it is made and
// the file is only how it survives a logout.
//
// Instantiated once at ShellRoot level and shared by every bar, so both
// screens are the same size and there is one writer to the config file.
Scope {
    id: root

    readonly property string home: Quickshell.env("HOME")
    readonly property string configHome: Quickshell.env("XDG_CONFIG_HOME") || (root.home + "/.config")

    readonly property string configPath: root.configHome + "/quickshell/bar.json"

    // The size the bar was tuned at, and what a machine with no config file
    // gets. It was a literal in Theme.qml before this section existed, and a
    // fresh session must still look exactly like it did then.
    readonly property real defaultZoom: 1.4

    // The ends of the slider, and the clamp below, from one pair of numbers so
    // the two cannot disagree. Below 0.8 the glyphs stop being comfortably
    // clickable; above 2 the bar is taking a fifth of a 1440p screen.
    readonly property real minZoom: 0.8
    readonly property real maxZoom: 2

    // What the Theme reads, rather than the raw setting. The slider cannot
    // leave the range, but a hand-edited bar.json can, and a zoom of 40 is a
    // bar with no room left for the settings button that would undo it.
    readonly property real zoom: Math.max(root.minZoom, Math.min(root.maxZoom, config.zoom))

    // Reached as `bar.settings.zoom`. One object rather than a proxy property
    // per field, for the same reason Wallpaper does it: the adapter already
    // gives every one of them change notification.
    readonly property alias settings: config

    // Shown under the controls. Empty means nothing to say.
    property string status: ""
    property bool failed: false

    // There is nothing to apply — the bar is already wearing the change by the
    // time this is called. This is only the part that has to outlive the
    // session.
    function persist() {
        root.failed = false;
        // Optimistic, and corrected by onSaveFailed, which fires after the
        // write rather than before it — so a failure cannot leave the
        // reassuring message as the last word.
        root.status = "Saved to " + root.configPath;
        configFile.writeAdapter();
    }

    function reset() {
        config.zoom = root.defaultZoom;
        root.persist();
    }

    FileView {
        id: configFile

        path: root.configPath
        // A torn write here costs the next session its bar size and nothing
        // worse, but the file is small enough that atomicity is free.
        atomicWrites: true
        printErrors: false
        // Someone may edit the file by hand. The clamp on `zoom` above is what
        // makes that safe to pick up live.
        watchChanges: true

        onFileChanged: configFile.reload()

        onSaveFailed: {
            root.failed = true;
            root.status = "Could not write " + root.configPath;
        }

        JsonAdapter {
            id: config

            property real zoom: root.defaultZoom

            // Off by default, and deliberately not derived from whether the
            // machine has a battery. The islands it adds already hide
            // themselves when nothing is reporting, so this is the *other*
            // question — whether a laptop wants them on the bar at all — and
            // that is not a thing to guess.
            //
            // The waybar this replaced gated the same two modules on the nix
            // variable `enableLaptopMode`, which is per host and takes a
            // rebuild. This is that setting, moved to where it can be answered
            // in a click. See ../../power/README.md.
            property bool laptopMode: false
        }
    }
}

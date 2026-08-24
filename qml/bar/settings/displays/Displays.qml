import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import QtQuick

// Monitor configuration: reading what Hyprland reports, and getting changes
// back into it.
//
// Two separate things have to happen for a change to stick.
//
//  1. `hyprctl eval` applies it to the running compositor. Note *eval*, not
//     `keyword` — this config drives Hyprland's lua parser, and `keyword`
//     answers "keyword can't work with non-legacy parsers. Use eval." eval
//     takes the same hl.*() calls the config file is written in.
//  2. Rewriting ~/.config/hypr/monitors.lua is what survives a reload. The
//     generated hyprland.lua dofile()s that file; see the extraConfig block in
//     modules/home/hyprland/default.nix, which has the note on why it is
//     dofile and not require.
//
// Applying without writing would silently revert on the next reload, and
// writing without applying would do nothing until then, so `apply()` does
// both and reports if either half fails.
Scope {
    id: root

    readonly property string configHome: Quickshell.env("XDG_CONFIG_HOME") || (Quickshell.env("HOME") + "/.config")
    readonly property string configPath: root.configHome + "/hypr/monitors.lua"

    // Shown under the buttons. Empty means nothing to say.
    property string status: ""
    property bool failed: false
    property bool busy: false

    // Held across the apply so the verify step can check what was asked for
    // against what Hyprland actually did.
    property var requested: []

    signal applied

    // ── VRR capability ─────────────────────────────────────────────────
    // Connector name -> bool, from vrrcap.sh. Hyprland reports whether VRR is
    // *on*, never whether the display could do it, so the answer has to come
    // from the DRM connector property instead. See the script.
    //
    // An output missing from here is unknown rather than incapable, and the
    // page leaves unknowns switchable: refusing a setting that would have
    // worked is worse than offering one Hyprland then declines, which the
    // post-apply check catches anyway.
    property var vrrCapable: ({})

    function vrrSupported(name) {
        return root.vrrCapable[name] ?? true;
    }

    // Cheap (~60ms) and only on the way in, so the page always opens against
    // the hardware that is plugged in now rather than a startup snapshot.
    function refreshCapabilities() {
        vrrProcess.running = true;
    }

    // Same idiom as connectivity/Net.qml and media/Cava.qml: resolved against
    // this file so it works from the store and from a working tree alike.
    readonly property string scriptPath: Qt.resolvedUrl("vrrcap.sh").toString().replace("file://", "")

    Process {
        id: vrrProcess

        command: ["bash", root.scriptPath]

        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    root.vrrCapable = JSON.parse(this.text);
                } catch (error) {
                    // A shell that cannot answer leaves every output unknown,
                    // which leaves every toggle live. Same outcome as the
                    // script's own `{}` fallback.
                    root.vrrCapable = ({});
                }
            }
        }
    }

    // ── Mode parsing ───────────────────────────────────────────────────
    // hyprctl reports availableModes as "3840x2160@144.00Hz" strings, and it
    // repeats itself — this machine lists 32 entries covering rather fewer
    // real modes. Splitting resolution from rate is what lets the two
    // selectors act independently, which is the part of ilyamiro's monitor
    // page worth taking: pick a resolution, then pick from the rates that
    // resolution actually supports.

    function ratesByResolution(modes) {
        const table = {};
        for (const mode of modes ?? []) {
            const at = mode.indexOf("@");
            if (at === -1)
                continue;
            const resolution = mode.substring(0, at);
            const rate = parseFloat(mode.substring(at + 1));
            if (!isFinite(rate))
                continue;
            if (!table[resolution])
                table[resolution] = [];
            // Rates that differ only past two decimals are the same mode
            // reported twice, and offering both would be a coin flip.
            if (!table[resolution].some(known => Math.abs(known - rate) < 0.01))
                table[resolution].push(rate);
        }
        for (const resolution in table)
            table[resolution].sort((a, b) => b - a);
        return table;
    }

    // Biggest first. The native mode is nearly always the one wanted and
    // nearly always the largest, so it lands at the top of the list.
    function resolutionsOf(table) {
        return Object.keys(table).sort((a, b) => {
            const left = a.split("x");
            const right = b.split("x");
            return (right[0] * right[1]) - (left[0] * left[1]);
        });
    }

    // Hyprland wants two decimals in a mode string and reports rates with
    // rather more, so both ends get rounded the same way or a mode that is
    // already set reads as a change.
    function modeString(resolution, rate) {
        return resolution + "@" + rate.toFixed(2);
    }

    function rateLabel(rate) {
        return rate.toFixed(2).replace(/\.?0+$/, "") + " Hz";
    }

    // The entry in `values` closest to `target`. Rates need it because
    // hyprctl's reported refreshRate (143.99899) never exactly equals the mode
    // list's (144.00); scales need it because the list of legal scales depends
    // on the resolution, so the one in use is not always in the new list at
    // all. One function rather than the loop written out at each of the three
    // call sites, which is what it was.
    function nearestIndex(values, target) {
        let best = 0;
        for (let i = 1; i < values.length; i++) {
            if (Math.abs(values[i] - target) < Math.abs(values[best] - target))
                best = i;
        }
        return best;
    }

    // ── Scale ──────────────────────────────────────────────────────────
    // Hyprland refuses a scale that does not divide the resolution into whole
    // logical pixels, so offering the full list would mostly be offering
    // errors. Filtering against the chosen resolution means everything shown
    // is something Hyprland will take.
    readonly property var scaleChoices: [1, 1.25, 1.333333, 1.5, 1.75, 2, 2.5, 3]

    function scalesFor(resolution) {
        const parts = resolution.split("x");
        const width = Number(parts[0]);
        const height = Number(parts[1]);
        return root.scaleChoices.filter(scale => {
            const logicalWidth = width / scale;
            const logicalHeight = height / scale;
            return Math.abs(logicalWidth - Math.round(logicalWidth)) < 0.001 && Math.abs(logicalHeight - Math.round(logicalHeight)) < 0.001;
        });
    }

    function scaleLabel(scale) {
        // 1.333333 is the only choice that is not exact, and "1.33x" is what
        // it is called everywhere else.
        return (Math.round(scale * 100) / 100) + "x";
    }

    // ── Applying ───────────────────────────────────────────────────────

    // `entries` is [{ output, mode, position, scale, vrr }]. Positions are
    // carried over from what Hyprland already reports: there is no arrange
    // canvas here, so a resolution change keeps each output's existing
    // top-left.
    //
    // vrr goes in the per-monitor rule rather than the global misc:vrr, so
    // one display can run adaptive while another stays fixed.
    function luaFor(entries) {
        const calls = entries.map(entry => `hl.monitor({
    output = "${entry.output}",
    mode = "${entry.mode}",
    position = "${entry.position}",
    scale = ${entry.scale},
    vrr = ${entry.vrr}
})`);

        return `-- Generated by the quickshell settings panel. Do not edit manually.
-- Rewritten in full every time Displays is applied.

${calls.join("\n")}
`;
    }

    function apply(entries) {
        if (root.busy || entries.length === 0)
            return;

        root.busy = true;
        root.failed = false;
        root.status = "Applying…";
        root.requested = entries;

        // Live first. There is no point writing a file that would fail the
        // same way on the next reload.
        applyProcess.command = ["hyprctl", "eval", root.luaFor(entries).split("\n").filter(line => !line.startsWith("--")).join("\n")];
        applyProcess.running = true;
    }

    Process {
        id: applyProcess

        stdout: StdioCollector {
            onStreamFinished: {
                // Whichever of this and onExited arrives first owns the
                // outcome. They are two reports of one run and can land in
                // either order, and without this guard a hyprctl that failed
                // *and* printed something would be announced as a failure and
                // then have its config written anyway.
                if (!root.busy)
                    return;

                // A lua error comes back on stdout rather than as an exit
                // code. Note that a *bad mode* does not: Hyprland accepts the
                // rule and quietly ignores it, which is why apply is followed
                // by a read-back rather than trusted on its own.
                if (this.text.trim().startsWith("error")) {
                    root.busy = false;
                    root.failed = true;
                    root.status = this.text.trim();
                    return;
                }
                config.setText(root.luaFor(root.requested));
            }
        }

        stderr: StdioCollector {
            id: applyErrors
        }

        // A backstop, not the path — the success path is the collector above.
        // It exists because that collector only speaks when there is something
        // on stdout, and the ways this call fails hardest are the ways that
        // produce none: hyprctl missing from PATH, or the compositor socket
        // gone. `busy` then stayed true for the rest of the session, with
        // Apply and Revert both disabled and "Applying…" as the last word.
        onExited: exitCode => {
            if (exitCode === 0 || !root.busy)
                return;
            root.busy = false;
            root.failed = true;
            root.status = applyErrors.text.trim() || ("hyprctl exited " + exitCode);
        }
    }

    // Written whole rather than patched: this file is generated output, and
    // half-updating it is how you end up with two rules for one output.
    FileView {
        id: config

        path: root.configPath
        // The compositor reads this on reload. A torn write would cost the
        // session its display config.
        atomicWrites: true
        printErrors: false

        onSaved: {
            root.attempt = 0;
            // One refresh up front so the loop's first read has something
            // newer than the state from before the apply.
            Hyprland.refreshMonitors();
            verify.restart();
        }

        onSaveFailed: {
            root.busy = false;
            root.failed = true;
            root.status = "Applied, but could not write " + root.configPath;
        }
    }

    // ── Reading back ───────────────────────────────────────────────────
    // A mode switch is not instant and is not atomic. Hyprland takes the
    // output down and brings it up again, and for as long as that lasts
    // `hyprctl monitors -j` reports it at 0x0 with a scale of 0 — which is not
    // "Hyprland refused the mode", it is "there is nothing to compare yet".
    //
    // This used to be one fixed wait: refresh after 700ms, compare 250ms after
    // that. On this hardware the switch takes longer than those 950ms, so the
    // comparison landed inside the reconfigure window and every *successful*
    // change was announced as "Hyprland did not take" — including the outputs
    // that were not being changed, because they blank along with it.
    //
    // Waiting longer is not the fix either, because the opposite error is just
    // as easy: compare too early in the other direction and the output is
    // still driving the *old* mode, which also does not match. There is no
    // single instant that is safe.
    //
    // So this polls to convergence instead. Every tick re-reads the outputs
    // and compares; the first tick where everything matches is the answer, and
    // anything still wrong when the deadline runs out is reported as refused.
    // A change that took is confirmed as soon as it lands, and one that did
    // not costs the full deadline before it is called — which is the right way
    // round, because the first case is nearly all of them.
    readonly property int settleInterval: 250
    // 6s. A 4K mode switch here settles in one to two, and a panel that
    // renegotiates a link slowly is exactly the one this must not accuse.
    readonly property int settleAttempts: 24

    property int attempt: 0

    // Outputs not doing what was asked. A monitor that is missing from the
    // list, or reporting zero size, counts as one of these — during a modeset
    // it is both, and neither means anything until it comes back.
    function mismatched() {
        const missed = [];

        for (const entry of root.requested) {
            const monitor = Hyprland.monitors.values.find(candidate => candidate.name === entry.output);
            if (!monitor || monitor.width === 0 || monitor.height === 0) {
                missed.push(entry.output);
                continue;
            }

            // "preferred" hands the choice to Hyprland, so there is nothing to
            // hold it to but the scale — see MonitorDraft.entry() for the one
            // case that writes it.
            const wantsMode = entry.mode !== "preferred";
            const actual = `${monitor.width}x${monitor.height}`;
            const wantedRate = wantsMode ? parseFloat(entry.mode.split("@")[1]) : NaN;
            const actualRate = monitor.lastIpcObject?.refreshRate ?? 0;

            // The rate is checked as well as the resolution, and it is the
            // half that used to be missed entirely: Hyprland takes
            // "3840x2160@144" on a panel that will only drive that rate at a
            // lower resolution, reports ok, brings the output up at 120, and
            // the panel said "Saved".
            //
            // A whole hertz of slack, because the two ends of this comparison
            // are never the same number — the mode list says 144.00 and the
            // monitor reports 143.99899. It is still far tighter than the gap
            // between any two rates a display actually offers, which is the
            // thing being caught.
            const rateMissed = isFinite(wantedRate) && Math.abs(actualRate - wantedRate) > 1;

            const modeMissed = wantsMode && (actual !== entry.mode.split("@")[0] || rateMissed);

            if (modeMissed || Math.abs(monitor.scale - entry.scale) > 0.01)
                missed.push(entry.output);
        }

        return missed;
    }

    // VRR is asked about separately because it not taking is not a failure.
    // Hyprland reads a monitor rule's vrr when it brings the output up and not
    // afterwards: setting the rule on a running session is accepted, reports
    // ok, and changes nothing — confirmed down at the DRM level, where
    // VRR_ENABLED stays 0. A `hyprctl reload` does not help either, and nor
    // does the global misc:vrr: setting that live moves the option but leaves
    // VRR_ENABLED at 0, and it would drag every output along with it anyway. So
    // the file is correct and the session catches up when Hyprland next starts.
    //
    // It is also why VRR is kept out of the settle loop above: waiting for it
    // to converge would mean waiting out the whole deadline every time it was
    // changed.
    function vrrPending() {
        return root.requested.some(entry => {
            const monitor = Hyprland.monitors.values.find(candidate => candidate.name === entry.output);
            if (!monitor)
                return false;
            return ((monitor.lastIpcObject?.vrr ?? false) ? 1 : 0) !== entry.vrr;
        });
    }

    function report(missed) {
        root.busy = false;
        root.failed = missed.length > 0;
        // Hyprland takes a monitor rule without complaint and then drops it if
        // the mode will not drive, so the only honest check is what the
        // outputs are actually doing afterwards.
        if (missed.length > 0)
            root.status = "Hyprland did not take: " + missed.join(", ");
        else if (root.vrrPending())
            root.status = "Saved. VRR applies the next time Hyprland starts.";
        else
            root.status = "Saved to " + root.configPath;
        root.applied();
    }

    Timer {
        id: verify

        interval: root.settleInterval
        repeat: true

        onTriggered: {
            // What the refresh asked for on the previous tick has landed by
            // now. Reading first and refreshing second is what puts a full
            // interval between the request and the read — `refreshMonitors()`
            // is a request over the IPC socket, not a fetch, and reading
            // straight after it would only ever see the state before it.
            const missed = root.mismatched();

            if (missed.length === 0 || root.attempt >= root.settleAttempts) {
                verify.stop();
                root.report(missed);
                return;
            }

            root.attempt++;
            Hyprland.refreshMonitors();
        }
    }
}

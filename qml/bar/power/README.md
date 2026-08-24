# Power

Laptop mode: the battery readout and the power profile switch, and the two
questions of whether this machine can answer for either.

| File | What it does |
| --- | --- |
| `Power.qml` | Battery, profiles, and what is actually reporting (non-visual) |
| `BatteryWidget.qml` | Glyph and percentage — a readout |
| `ProfileWidget.qml` | Glyph and profile name — click or scroll to step |
| `profiles.sh` | Which profiles power-profiles-daemon offers, as `["balanced",…]` |

Used from `../shell.qml`, which makes one shared state object and puts each
widget in an island of its own:

```qml
Power { id: powerState }        // shared, once
...
Island {
    visible: barState.settings.laptopMode && powerState.batteryAvailable
    BatteryWidget { theme: barTheme; power: powerState }
}
Island {
    visible: barState.settings.laptopMode && powerState.profilesAvailable
    ProfileWidget { theme: barTheme; power: powerState }
}
```

## Where they sit, and why that needs no rule

Both islands are declared **after the media island** in the left-hand row. That
puts them next to the player — and next to the audio pane instead whenever
there is no player, because a `Row` skips children that are not visible and the
media island hides itself when `mediaState.player` is null.

One placement, both cases. A rule that picked a position based on whether a
player was running would have to be re-evaluated as players come and go, and
would be a second thing to keep in step with the media island's own visibility.

## Two islands, not one

A charge level is a readout and a power profile is a control, and the only
thing they have in common is the word "power". The audio pair share a pane
because they are two of the same thing — a sink and a source — which is the
test that decides this everywhere else on the bar.

## Turning it on

The switch is in the settings panel's Bar section, persisted as `laptopMode` in
`~/.config/quickshell/bar.json`. See `../settings/bar/README.md`.

The waybar this bar replaced gated the same two modules on the nix variable
`enableLaptopMode`, which is per host and takes a rebuild to change. That
variable is still set on `phobos` and is now read by nothing; the panel's toggle
is its replacement.

## Availability is asked twice, separately

Nothing here assumes that having a battery means having power profiles. A
desktop has neither. `mercury` has profiles and no battery. A laptop with no
performance platform driver has a battery and *two* profiles rather than three.
Each island is bound to its own source, so laptop mode on a machine that
reports only one of the two shows only that one, and the settings page names
what it found either way.

**The battery** is `UPower.displayDevice` — the aggregate UPower synthesises,
not a device picked out of `UPower.devices`. A laptop with two batteries has two
devices and one charge level, and the aggregate is what reports it.

`batteryAvailable` is `isLaptopBattery && isPresent`. The first is UPower's own
`type == Battery && powerSupply`, and the daemon sets both on the aggregate
device only once it has a real battery to aggregate — on a desktop the type
stays `Unknown`. `isPresent` covers the hot-removable case on top of that. With
no UPower on the bus at all — the case on `mercury`, where the service is not
even activatable — quickshell logs

```
Could not launch service org.freedesktop.UPower: The name is not activatable
```

and every property stays at its default, which lands as unavailable. That is
why `services.upower.enable` is on in `modules/core/power-profile.nix`: without
it a *laptop* would look exactly like this too.

**The profiles** need a script, and this is the awkward part.
Quickshell's `PowerProfiles` can say which profile is active and whether a
performance profile exists, but has no property for whether the daemon is
running: with ppd stopped it simply reports the default, `Balanced`, which is
indistinguishable from a machine sitting in Balanced. So `profiles.sh` asks
DBus directly, and its answer doubles as the list of modes this machine has.

It costs no new dependency — `busctl` comes from systemd and `jq` was already
there, both for other parts of the bar.

The script runs at startup and again each time the settings panel opens, the
same bargain `../settings/displays/vrrcap.sh` makes: ppd can be started or
stopped under a running session, and naming a stale answer on the page is worse
than spending 50ms to ask again.

**Performance carries a second condition.** Quickshell refuses to write that
profile unless `hasPerformanceProfile` is true, and that property arrives from
an async DBus reply about a second after start — so it is ANDed into the filter.
Without it, a click in the first second of the session would be a click that
silently did nothing. Everything here is a binding, so the option appears when
the answer does.

## Percentages

UPower reports `Percentage` as 0–100 and Quickshell divides it by 100 on the way
through (`DBusDataTransform<PowerPercentage>::fromWire` is `wire * 0.01`), so
`Power.percent` is the one place that multiplies it back.

## Glyphs and thresholds

Carried over from the waybar module wholesale, so the bar reads the same way it
did before the migration:

| | |
| --- | --- |
| level | ten-step ramp, `󰁺` through `󰁹` |
| charging | `󰂄`, waybar's `format-charging` |
| full | `󰚥`, waybar's `format-plugged` |
| warning | 30%, drawn in `theme.warn` |
| critical | 15%, drawn in `theme.bad` |

Both thresholds are **discharging only**. A battery climbing back through 12% on
the charger is not a warning, it is the fix already in progress.

The colours are the three fixed ones — see `../theme/README.md` on why `good`,
`warn` and `bad` are the colours the wallpaper does not get to move. A battery
at 12% is not a styling opportunity.

Profile glyphs are waybar's too: `` leaf, `` scales, `` bolt.

## Stepping rather than choosing

Clicking the profile widget steps to the next profile and scrolling moves either
way. There are two or three of them and they are ordered by how hard the machine
is allowed to work, so this is a switch and not a choice — the same bargain the
audio pill makes when it puts volume on the wheel rather than opening a slider.

A profile that is not in the list — ppd sitting in something this machine did
not report — counts as *before* the start, so the first step lands on index 0
rather than skipping it.

## The battery does not click

waybar bound no `on-click` here either, and there is nothing this could
usefully do that the settings panel does not already do better. It still glows
under the pointer, because every other label on the bar does and the one that
did not would read as broken rather than as inert — the clock is the precedent.
It does not take the pointing-hand cursor, though: that is a promise of
something to click.

## Widths are reserved

Both widgets size themselves with `TextMetrics` over the widest string they can
ever hold, rather than hugging the current one. A discharging battery steps
through 100, 99, 9 and a stepping profile goes from `Saver` to `Performance` —
a widget that hugs its text drags its island, and everything right of it,
sideways every time. Same reasoning as `../system/ResourcesWidget.qml`, where
the CPU readout moves twice a second.

The profile width is measured over the *available* profiles rather than all
three: a laptop with no performance mode should not carry the width of a word it
will never show.

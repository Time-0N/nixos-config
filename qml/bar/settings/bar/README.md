# Bar

The Bar section: how big the bar is drawn.

| File | What it does |
| --- | --- |
| `Bar.qml` | The setting, clamped, and the config file it lives in (non-visual) |
| `BarPage.qml` | The page |

## What it actually moves

One number, `Theme.zoom`. Every metric in `../../theme/Theme.qml` is a base
value times it — the bar's height, the islands, the pill radii, the gaps, the
glyph and label sizes — so the whole bar resizes as one thing rather than as
twenty numbers that have to be kept in step.

```
   panel ──▶ bar.settings.zoom ──▶ Bar.zoom ──▶ Theme.zoom ──▶ every metric
                    │
                    └──▶ ~/.config/quickshell/bar.json   (on release only)
```

That is the whole apply path. Nothing outside the shell reads the file, so
there is no unit to restart and no state file to read back — the config is only
how the choice outlives the session.

**`shell.qml` sets `zoom` on both themes**, not just `barTheme`. The media
widget is drawn from `baseTheme` — it is held out of the wallpaper palette, see
`../../theme/README.md` — and a zoom set on one theme would have resized every
island except that one.

**The exclusive zone follows.** `exclusiveZone` in `shell.qml` is
`barHeight + barMargin`, so tiled windows reflow to the new size as the slider
moves rather than the next time something happens to retrigger layout.

## Live, not drafted

Dragging the slider resizes the bar immediately; only letting go writes the
file. That is the Wallpaper page's bargain rather than the Displays page's, and
for the same reason: the bar sits above the panel — dimmed by the backdrop, but
never covered — so the drag is its own preview, and a wrong size costs one more
drag to undo. A monitor mode can leave a screen you cannot see well enough to
fix; a 90% bar cannot.

Writing on release rather than on every notch is not about the cost of a write.
The range is twenty-four notches and the obvious way to find a size is to
sweep it, which would be twenty-four rewrites of a file recording one decision.

## The clamp

`Bar.zoom` is `settings.zoom` clamped to `minZoom`–`maxZoom`, and the Theme
binds to the clamped one. The slider cannot leave the range, but `bar.json` is
watched for hand edits, and a `zoom` of 40 is a bar with no room left for the
settings button that would undo it.

The slider takes its own `from`/`to` from those same two properties, so the
bounds the panel offers and the bounds the file is held to are one pair of
numbers rather than two that can drift apart.

## The default is in two places, deliberately

`defaultZoom` here and the literal on `Theme.zoom` are both 1.4. The Theme's
copy is what a `Theme` built without the settings binding draws at, which is
what makes the type usable on its own; this one is what a machine with no
`bar.json` gets, and what the Reset button restores. Both are commented as
pointing at the other. A single source would mean `Theme` importing a settings
section, which is backwards — the theme is what settings are applied *to*.

## What does not scale

The settings window, the cards the bar opens, and the tray menu. They are sized
in plain pixels and read nothing from `zoom` — they are already sized to be
read, and a 140% settings dialog is a worse settings dialog. Only bar chrome
and bar text follow the slider.

## One number for every output

`Theme` is a single object shared by every bar, so the scale is too. Per-monitor
sizing would mean a `Theme` per screen and a palette per screen underneath it,
which is a much larger change than the setting is worth — and it is the wrong
lever for the usual reason to want it. A HiDPI output should be corrected with
its own Hyprland `scale`, on the Displays page, which fixes every application on
that screen rather than just this bar.

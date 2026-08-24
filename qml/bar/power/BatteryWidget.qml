import QtQuick

import "../theme"

// Charge level, as waybar's #battery drew it: one glyph off a ten-step ramp,
// then the number.
//
// A readout and nothing else. waybar bound no `on-click` here either, and
// there is nothing this could usefully do that the settings panel does not
// already do better. It still answers the pointer, because every other label
// on the bar does and the one that did not would read as broken rather than as
// inert — see the clock, which glows and does nothing for the same reason.
Item {
    id: widget

    required property var theme
    required property var power

    // Reserved at the widest string this can ever hold rather than hugging the
    // current one. A discharging battery steps down through 100, 99, 9 — and a
    // readout that hugs its text drags the whole island, and everything right
    // of it, sideways each time a digit is lost.
    implicitWidth: metrics.width
    implicitHeight: widget.theme.controlSize

    TextMetrics {
        id: metrics

        font: label.font
        text: "󰂄 100%"
    }

    PulseText {
        id: label

        anchors.centerIn: parent

        theme: widget.theme
        text: widget.power.batteryGlyph + " " + widget.power.percent + "%"
        lit: pointer.containsMouse
        // The three fixed colours, used for exactly what they mean. A battery
        // at 12% is not a styling opportunity — see ../theme/Theme.qml on why
        // these three are the ones the wallpaper does not get to move.
        color: {
            if (widget.power.critical)
                return widget.theme.bad;
            if (widget.power.low)
                return widget.theme.warn;
            if (widget.power.charging)
                return widget.theme.good;
            return pointer.containsMouse ? widget.theme.hover : widget.theme.fg;
        }
        // Held state beats hover, the same order IdleWidget lands on: a
        // critical battery that turned pink under the pointer would read as
        // the warning having gone away.
        glowColor: widget.power.critical ? widget.theme.bad : (widget.power.low ? widget.theme.warn : widget.theme.hover)
        font.pixelSize: widget.theme.fontSize
    }

    MouseArea {
        id: pointer

        anchors.fill: parent
        hoverEnabled: true
        // No pointing hand: there is nothing here to click, and a cursor that
        // says otherwise is a promise the widget does not keep.
    }
}

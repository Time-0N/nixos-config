import QtQuick

import "../theme"

// The power profile, as waybar's #power-profiles-daemon module drew it — the
// same three glyphs — except that this one can also change it, which that
// module could not.
//
// Click steps to the next profile, scroll steps either way. There are two or
// three of these and they are ordered by how hard the machine is allowed to
// work, so stepping is the honest control: a menu would be three lines of
// chrome over a decision with one axis. It is the same bargain the audio pill
// makes when it puts volume on the wheel.
Item {
    id: widget

    required property var theme
    required property var power

    readonly property var profile: widget.power.currentProfile

    // Wide enough for the longest label this machine can show, so stepping
    // through the profiles does not shove the rest of the bar sideways.
    // Measured over the available profiles rather than all three: a laptop
    // with no performance mode should not carry the width of the word.
    implicitWidth: metrics.width
    implicitHeight: widget.theme.controlSize

    TextMetrics {
        id: metrics

        font: label.font
        text: {
            let widest = "";
            for (const profile of widget.power.profiles) {
                const candidate = profile.glyph + " " + profile.label;
                if (candidate.length > widest.length)
                    widest = candidate;
            }
            return widest;
        }
    }

    PulseText {
        id: label

        anchors.centerIn: parent

        theme: widget.theme
        text: widget.profile ? widget.profile.glyph + " " + widget.profile.label : ""
        lit: pointer.containsMouse
        color: pointer.containsMouse ? widget.theme.hover : widget.theme.fg
        glowColor: widget.theme.hover
        font.pixelSize: widget.theme.fontSize
    }

    MouseArea {
        id: pointer

        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: widget.power.cycle(1)
        // Up is towards performance, matching the order the labels step in.
        onWheel: wheel => widget.power.cycle(wheel.angleDelta.y > 0 ? 1 : -1)
    }
}

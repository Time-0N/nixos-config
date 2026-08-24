import QtQuick
import QtQuick.Layouts

import "../common"

// The Bar page: how big the bar is.
//
// Applied as it is dragged, which is the Wallpaper page's bargain rather than
// the Displays page's and for the same reason. The thing being changed is
// visible the whole time — the bar sits above the panel, dimmed by the
// backdrop but not covered — so the drag is its own preview, and drafting it
// would only put a button between someone and the size they are hunting for.
// A wrong one is also free to undo, which is what a monitor mode is not.
//
// Only the release writes the file. Dragging across the range is twenty-four
// notches, and each of them rewriting bar.json would be twenty-four writes
// recording one decision.
Item {
    id: page

    required property var theme
    required property var bar

    // The clamped value rather than the raw setting, so the readouts and the
    // handle agree with the bar even when a hand-edited config put something
    // silly in the file. Writes still go to `settings.zoom` — this is what the
    // bar is, that is what was asked for.
    readonly property real zoom: page.bar.zoom

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 18
        spacing: 12

        Text {
            Layout.fillWidth: true
            text: "Bar"
            color: page.theme.fg
            font.family: page.theme.fontFamily
            font.bold: true
            font.pixelSize: 17
        }

        // ── Settings ───────────────────────────────────────────────────
        Flickable {
            Layout.fillWidth: true
            Layout.fillHeight: true
            contentHeight: detail.implicitHeight
            clip: true
            boundsBehavior: Flickable.StopAtBounds

            GridLayout {
                id: detail

                // The same cap and alignment the other two pages use. The
                // sections are one click apart, and a form that changes width
                // between them reads as a bug rather than as three pages.
                width: Math.min(560, parent.width)
                columns: 2
                columnSpacing: 12
                rowSpacing: 10

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 1

                    Text {
                        text: "Scale"
                        color: page.theme.fg
                        font.family: page.theme.fontFamily
                        font.pixelSize: 12
                    }

                    Text {
                        Layout.fillWidth: true
                        text: "Every size on the bar at once — the islands, the glyphs, the labels and the gaps between them."
                        color: page.theme.dim
                        font.family: page.theme.fontFamily
                        font.pixelSize: 10
                        wrapMode: Text.WordWrap
                    }
                }

                Slider {
                    theme: page.theme
                    Layout.alignment: Qt.AlignRight | Qt.AlignTop
                    // Both ends from the state object, so the slider and the
                    // clamp guarding the config file are one pair of numbers.
                    from: page.bar.minZoom
                    to: page.bar.maxZoom
                    // 5% a notch. Finer than that and the bar shifts by less
                    // than a pixel per step, which is a slider that does
                    // nothing for a third of its travel.
                    stepSize: 0.05
                    value: page.zoom
                    display: Math.round(page.zoom * 100) + "%"

                    // Moved is the preview and the write both: the bar is
                    // bound to this value, so setting it *is* showing it.
                    onMoved: value => page.bar.settings.zoom = value
                    onCommitted: value => {
                        page.bar.settings.zoom = value;
                        page.bar.persist();
                    }
                }

                // What the percentage comes to. A ratio means nothing on its
                // own, and the height is the number that decides whether the
                // bar is worth the strip of screen it costs. Read off `theme`
                // rather than recomputed, so this cannot drift from the
                // arithmetic in Theme.qml.
                Text {
                    Layout.fillWidth: true
                    Layout.columnSpan: 2
                    text: page.theme.barHeight + " px tall, reserving " + (page.theme.barHeight + page.theme.barMargin) + " px from the top of the screen, with " + page.theme.fontSize + " px labels."
                    color: page.theme.dim
                    font.family: page.theme.fontFamily
                    font.pixelSize: 10
                    wrapMode: Text.WordWrap
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.columnSpan: 2
                    Layout.topMargin: 2
                    Layout.bottomMargin: 2
                    implicitHeight: 1
                    color: Qt.rgba(page.theme.fg.r, page.theme.fg.g, page.theme.fg.b, 0.1)
                }

                Text {
                    Layout.fillWidth: true
                    Layout.columnSpan: 2
                    text: "This window, the cards the bar opens and the tray menu keep their own size. They are already sized to be read, and a 140% settings dialog is a worse settings dialog."
                    color: page.theme.dim
                    font.family: page.theme.fontFamily
                    font.pixelSize: 10
                    wrapMode: Text.WordWrap
                }
            }
        }

        // ── Footer ─────────────────────────────────────────────────────
        // No Apply, for the reason at the top of the file. The one button
        // undoes a hunt that went nowhere.
        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            Text {
                Layout.fillWidth: true
                text: page.bar.status
                color: page.bar.failed ? page.theme.bad : page.theme.dim
                font.family: page.theme.fontFamily
                font.pixelSize: 11
                elide: Text.ElideRight
            }

            Button {
                theme: page.theme
                label: "Reset to " + Math.round(page.bar.defaultZoom * 100) + "%"
                // Compared with a tolerance rather than exactly: the slider
                // quantises to six decimal places and the file round-trips
                // through JSON, so a value that came back as 1.3999999999 is
                // the default and the button should know it.
                enabled: Math.abs(page.zoom - page.bar.defaultZoom) > 0.001
                onTriggered: page.bar.reset()
            }
        }
    }
}

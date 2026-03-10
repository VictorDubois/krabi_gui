import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "components"

Item {
    id: root
    required property var palette

    Rectangle { anchors.fill: parent; color: root.palette.bg }

    ColumnLayout {
        anchors.centerIn: parent
        width: Math.min(parent.width - 40, 600)
        spacing: 0

        // ── Team colour ───────────────────────────────────────────────
        Text {
            Layout.alignment: Qt.AlignHCenter
            text: "COULEUR D'ÉQUIPE"
            color: root.palette.textSec
            font.pixelSize: 11
            font.letterSpacing: 2
            font.weight: Font.Medium
        }

        Item { Layout.preferredHeight: 10 }

        Row {
            Layout.alignment: Qt.AlignHCenter
            spacing: 16

            // Blue
            Rectangle {
                width: 160; height: 72
                radius: 12
                color:        match.teamColor === "blue" ? "#1e3a8a" : root.palette.surface
                border.color: match.teamColor === "blue" ? "#3b82f6" : root.palette.border
                border.width: match.teamColor === "blue" ? 2 : 1

                Behavior on color        { ColorAnimation { duration: 200 } }
                Behavior on border.color { ColorAnimation { duration: 200 } }

                // Glow
                Rectangle {
                    anchors.fill: parent; radius: parent.radius
                    color: "transparent"
                    border.color: "#3b82f6"
                    border.width: match.teamColor === "blue" ? 6 : 0
                    opacity: 0.25
                    Behavior on border.width { NumberAnimation { duration: 200 } }
                }

                Text {
                    anchors.centerIn: parent
                    text: "BLEU"
                    color: match.teamColor === "blue" ? "#93c5fd" : root.palette.textSec
                    font.pixelSize: 18
                    font.weight: Font.Bold
                    font.letterSpacing: 2
                    Behavior on color { ColorAnimation { duration: 200 } }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: match.setTeamColor("blue")
                }
            }

            // Yellow
            Rectangle {
                width: 160; height: 72
                radius: 12
                color:        match.teamColor === "yellow" ? "#422006" : root.palette.surface
                border.color: match.teamColor === "yellow" ? "#f59e0b" : root.palette.border
                border.width: match.teamColor === "yellow" ? 2 : 1

                Behavior on color        { ColorAnimation { duration: 200 } }
                Behavior on border.color { ColorAnimation { duration: 200 } }

                Rectangle {
                    anchors.fill: parent; radius: parent.radius
                    color: "transparent"
                    border.color: "#f59e0b"
                    border.width: match.teamColor === "yellow" ? 6 : 0
                    opacity: 0.25
                    Behavior on border.width { NumberAnimation { duration: 200 } }
                }

                Text {
                    anchors.centerIn: parent
                    text: "JAUNE"
                    color: match.teamColor === "yellow" ? "#fcd34d" : root.palette.textSec
                    font.pixelSize: 18
                    font.weight: Font.Bold
                    font.letterSpacing: 2
                    Behavior on color { ColorAnimation { duration: 200 } }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: match.setTeamColor("yellow")
                }
            }
        }

        Item { Layout.preferredHeight: 24 }

        // ── Strategy ──────────────────────────────────────────────────
        Text {
            Layout.alignment: Qt.AlignHCenter
            text: "STRATÉGIE"
            color: root.palette.textSec
            font.pixelSize: 11
            font.letterSpacing: 2
            font.weight: Font.Medium
        }

        Item { Layout.preferredHeight: 10 }

        Rectangle {
            Layout.alignment: Qt.AlignHCenter
            width: 200; height: 44
            radius: 10
            color: root.palette.surface
            border.color: root.palette.border
            border.width: 1

            Text {
                anchors.centerIn: parent
                text: "— à définir —"
                color: root.palette.textSec
                font.pixelSize: 13
                font.italic: true
            }

            MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor }
        }

        Item { Layout.preferredHeight: 32 }

        // ── Actions ───────────────────────────────────────────────────
        Row {
            Layout.alignment: Qt.AlignHCenter
            spacing: 16

            // Cancel
            Rectangle {
                width: 150; height: 52
                radius: 10
                color: cancelArea.pressed ? "#7f1d1d"
                     : cancelArea.containsMouse ? "#991b1b"
                     : "#1f0e0e"
                border.color: "#ef4444"
                border.width: 1

                Behavior on color { ColorAnimation { duration: 150 } }

                Text {
                    anchors.centerIn: parent
                    text: "ANNULER"
                    color: "#fca5a5"
                    font.pixelSize: 13
                    font.weight: Font.DemiBold
                    font.letterSpacing: 1
                }
                MouseArea {
                    id: cancelArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: match.stop()
                }
            }

            // GO
            Rectangle {
                width: 150; height: 52
                radius: 10
                color: goArea.pressed ? "#14532d"
                     : goArea.containsMouse ? "#15803d"
                     : "#052e16"
                border.color: "#22c55e"
                border.width: 1

                Behavior on color { ColorAnimation { duration: 150 } }

                Text {
                    anchors.centerIn: parent
                    text: "GO !"
                    color: "#86efac"
                    font.pixelSize: 16
                    font.weight: Font.Bold
                    font.letterSpacing: 2
                }
                MouseArea {
                    id: goArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: match.start()
                }
            }
        }
    }
}

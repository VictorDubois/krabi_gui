import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "components"

Item {
    id: root
    required property var palette

    // After RESTART COLOR, the old stack may still be talking
    readonly property string robotColor: match.teamColorKnown && !preMatch.restarting ? match.teamColor : ""
    readonly property bool tiretteKnown: tirette.known && !preMatch.restarting

    Rectangle { anchors.fill: parent; color: root.palette.bg }

    ColumnLayout {
        anchors.centerIn: parent
        width: Math.min(parent.width - 40, 600)
        spacing: 0

        // ── Team colour ───────────────────────────────────────────────
        Text {
            Layout.alignment: Qt.AlignHCenter
            text: match.teamColorEditable ? "COULEUR D'ÉQUIPE"
                : root.robotColor !== ""  ? "COULEUR LUE PAR LE ROBOT"
                :                           "COULEUR PAS ENCORE LUE"
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
                color:        root.robotColor === "blue" ? "#1e3a8a" : root.palette.surface
                border.color: root.robotColor === "blue" ? "#3b82f6" : root.palette.border
                border.width: root.robotColor === "blue" ? 2 : 1

                Behavior on color        { ColorAnimation { duration: 200 } }
                Behavior on border.color { ColorAnimation { duration: 200 } }

                // Glow
                Rectangle {
                    anchors.fill: parent; radius: parent.radius
                    color: "transparent"
                    border.color: "#3b82f6"
                    border.width: root.robotColor === "blue" ? 6 : 0
                    opacity: 0.25
                    Behavior on border.width { NumberAnimation { duration: 200 } }
                }

                Text {
                    anchors.centerIn: parent
                    text: "BLEU"
                    color: root.robotColor === "blue" ? "#93c5fd" : root.palette.textSec
                    font.pixelSize: 18
                    font.weight: Font.Bold
                    font.letterSpacing: 2
                    Behavior on color { ColorAnimation { duration: 200 } }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    enabled: match.teamColorEditable
                    onClicked: match.setTeamColor("blue")
                }
            }

            // Yellow
            Rectangle {
                width: 160; height: 72
                radius: 12
                color:        root.robotColor === "yellow" ? "#422006" : root.palette.surface
                border.color: root.robotColor === "yellow" ? "#f59e0b" : root.palette.border
                border.width: root.robotColor === "yellow" ? 2 : 1

                Behavior on color        { ColorAnimation { duration: 200 } }
                Behavior on border.color { ColorAnimation { duration: 200 } }

                Rectangle {
                    anchors.fill: parent; radius: parent.radius
                    color: "transparent"
                    border.color: "#f59e0b"
                    border.width: root.robotColor === "yellow" ? 6 : 0
                    opacity: 0.25
                    Behavior on border.width { NumberAnimation { duration: 200 } }
                }

                Text {
                    anchors.centerIn: parent
                    text: "JAUNE"
                    color: root.robotColor === "yellow" ? "#fcd34d" : root.palette.textSec
                    font.pixelSize: 18
                    font.weight: Font.Bold
                    font.letterSpacing: 2
                    Behavior on color { ColorAnimation { duration: 200 } }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    enabled: match.teamColorEditable
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

        Item { Layout.preferredHeight: 24 }

        // ── Tirette ───────────────────────────────────────────────────
        Text {
            Layout.alignment: Qt.AlignHCenter
            text: "TIRETTE"
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
            color: !root.tiretteKnown ? root.palette.surface : tirette.inserted ? "#052e16" : "#1f0e0e"
            border.color: !root.tiretteKnown ? root.palette.border : tirette.inserted ? "#22c55e" : "#ef4444"
            border.width: 1
            Behavior on color        { ColorAnimation { duration: 250 } }
            Behavior on border.color { ColorAnimation { duration: 250 } }

            Row {
                anchors.centerIn: parent
                spacing: 8

                Rectangle {
                    width: 10; height: 10
                    radius: 5
                    anchors.verticalCenter: parent.verticalCenter
                    color: !root.tiretteKnown ? root.palette.border : tirette.inserted ? "#22c55e" : "#ef4444"
                    Behavior on color { ColorAnimation { duration: 250 } }
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: !root.tiretteKnown ? "TIRETTE ?" : tirette.inserted ? "TIRETTE EN PLACE" : "TIRETTE ABSENTE"
                    color: !root.tiretteKnown ? root.palette.textSec : tirette.inserted ? "#86efac" : "#fca5a5"
                    font.pixelSize: 13
                    font.weight: Font.DemiBold
                    font.letterSpacing: 1
                    Behavior on color { ColorAnimation { duration: 250 } }
                }
            }
        }

        Item { Layout.preferredHeight: 24 }

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

    // ── Poweroff button — bottom-left corner ──────────────────────────────
    Rectangle {
        id:                   pwrBtn
        anchors.left:         parent.left
        anchors.bottom:       parent.bottom
        anchors.leftMargin:   12
        anchors.bottomMargin: 12
        width: 96; height: 36
        radius:       8
        color:        pwrArea.pressed       ? "#7f1d1d"
                    : pwrArea.containsMouse ? "#3d1010"
                    : "#1f0e0e"
        border.color: "#ef4444"
        border.width: 1
        Behavior on color { ColorAnimation { duration: 150 } }

        Text {
            anchors.centerIn:  parent
            text:              "ÉTEINDRE"
            color:             "#fca5a5"
            font.pixelSize:    12
            font.weight:       Font.DemiBold
            font.letterSpacing: 1
        }
        MouseArea {
            id:           pwrArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape:  Qt.PointingHandCursor
            onClicked:    confirmPoweroff.visible = true
        }
    }

    // ── REC toggle — bottom-left, right of poweroff ───────────────────────
    Rectangle {
        anchors.left:         pwrBtn.right
        anchors.bottom:       parent.bottom
        anchors.leftMargin:   8
        anchors.bottomMargin: 12
        width: 80; height: 36
        radius:       8
        color:        diagnostics.recording ? "#7f1d1d" : "#1a1000"
        border.color: diagnostics.recording ? "#ef4444" : "#374151"
        border.width: 1
        Behavior on color        { ColorAnimation { duration: 150 } }
        Behavior on border.color { ColorAnimation { duration: 150 } }

        Row {
            anchors.centerIn: parent
            spacing: 6

            Rectangle {
                width: 8; height: 8; radius: 4
                anchors.verticalCenter: parent.verticalCenter
                color: diagnostics.recording ? "#ef4444" : "#374151"
                Behavior on color { ColorAnimation { duration: 150 } }
            }
            Text {
                anchors.verticalCenter: parent.verticalCenter
                text:  "REC"
                color: diagnostics.recording ? "#fca5a5" : "#6b7280"
                font.pixelSize: 12; font.family: "Monospace"; font.weight: Font.Bold
            }
        }
        MouseArea {
            anchors.fill: parent; cursorShape: Qt.PointingHandCursor
            onClicked: diagnostics.toggleRecording()
        }
    }

    // ── Restart krabi_color — bottom-right corner ──────────────────────────
    Rectangle {
        anchors.right:        parent.right
        anchors.bottom:       parent.bottom
        anchors.rightMargin:  12
        anchors.bottomMargin: 12
        width: 124; height: 36
        radius:       8
        color:        restartArea.pressed       ? "#422006"
                    : restartArea.containsMouse ? "#2a1a00"
                    : "#1a1000"
        border.color: preMatch.canRestart ? "#f59e0b" : root.palette.border
        border.width: 1
        Behavior on color { ColorAnimation { duration: 150 } }

        Text {
            anchors.centerIn:   parent
            text:               "RESTART COLOR"
            color:              preMatch.canRestart ? "#fcd34d" : root.palette.textSec
            font.pixelSize:     11
            font.weight:        Font.DemiBold
            font.letterSpacing: 1
        }
        MouseArea {
            id:           restartArea
            anchors.fill: parent
            enabled:      preMatch.canRestart   // never during a match
            hoverEnabled: true
            cursorShape:  Qt.PointingHandCursor
            onClicked:    confirmRestart.visible = true
        }
    }

    ConfirmDialog {
        id: confirmRestart
        palette:     root.palette
        title:       "RELANCER LE ROBOT ?"
        detail:      "ROS redémarre : la couleur est relue, le recalage et la position sont remis à zéro."
        confirmText: "RELANCER"
        accent:      "#f59e0b"
        accentBg:    "#1a1000"
        accentText:  "#fcd34d"
        onConfirmed: preMatch.restart()
    }

    ConfirmDialog {
        id: confirmPoweroff
        palette:     root.palette
        title:       "ÉTEINDRE LE ROBOT ?"
        confirmText: "ÉTEINDRE"
        onConfirmed: diagnostics.poweroff()
    }
}

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root
    required property var palette

    Rectangle { anchors.fill: parent; color: root.palette.bg }

    ColumnLayout {
        anchors.centerIn: parent
        width: Math.min(parent.width - 40, 500)
        spacing: 0

        // ── Current step ──────────────────────────────────────────────
        Text {
            Layout.alignment: Qt.AlignHCenter
            text: "ÉTAPE"
            color: root.palette.textSec
            font.pixelSize: 11
            font.letterSpacing: 2
            font.weight: Font.Medium
        }

        Item { Layout.preferredHeight: 8 }

        Rectangle {
            Layout.alignment: Qt.AlignHCenter
            Layout.fillWidth: true
            height: 40
            radius: 8
            color:        root.palette.surface
            border.color: root.palette.border
            border.width: 1

            Text {
                anchors.centerIn: parent
                text:  match.strategyStep !== "" ? match.strategyStep : "En attente…"
                color: match.strategyStep !== "" ? root.palette.textPri : root.palette.textSec
                font.pixelSize: 14
                font.italic: match.strategyStep === ""
                font.weight: Font.Medium
            }
        }

        Item { Layout.preferredHeight: 28 }

        // ── Remaining time ────────────────────────────────────────────
        Text {
            Layout.alignment: Qt.AlignHCenter
            text: "TEMPS RESTANT"
            color: root.palette.textSec
            font.pixelSize: 11
            font.letterSpacing: 2
            font.weight: Font.Medium
        }

        Item { Layout.preferredHeight: 4 }

        Text {
            Layout.alignment: Qt.AlignHCenter
            text: match.timeRemaining + "s"
            font.pixelSize: 96
            font.weight: Font.Bold
            color: match.timeRemaining <= 10 ? "#ef4444" : "#22c55e"

            Behavior on color { ColorAnimation { duration: 400 } }
        }

        Item { Layout.preferredHeight: 16 }

        // ── Score ─────────────────────────────────────────────────────
        Text {
            Layout.alignment: Qt.AlignHCenter
            text: "SCORE"
            color: root.palette.textSec
            font.pixelSize: 11
            font.letterSpacing: 2
            font.weight: Font.Medium
        }

        Item { Layout.preferredHeight: 4 }

        Text {
            Layout.alignment: Qt.AlignHCenter
            text: match.score
            color: root.palette.textPri
            font.pixelSize: 52
            font.weight: Font.Bold
        }
    }
}

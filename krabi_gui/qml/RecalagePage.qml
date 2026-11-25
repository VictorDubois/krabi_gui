import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "components"

// Recalage on the borders: choose where the robot is put, then start. Possible with or without
// the tirette; the zones and their sequences come from the robot (goal_strategy/config).
Item {
    id: root
    required property var palette

    readonly property var zone: {
        for (var i = 0; i < preMatch.zones.length; i++)
            if (preMatch.zones[i].name === preMatch.selectedZone)
                return preMatch.zones[i]
        return null
    }

    Rectangle { anchors.fill: parent; color: root.palette.bg }

    RowLayout {
        anchors { fill: parent; margins: 10 }
        spacing: 12

        ZoneMap {
            Layout.fillWidth:  true
            Layout.fillHeight: true
        }

        // ── Zone list and start ──────────────────────────────────────────
        ColumnLayout {
            Layout.preferredWidth: 220
            Layout.maximumWidth:   220
            Layout.fillWidth:      false
            Layout.fillHeight: true
            spacing: 8

            Text {
                Layout.alignment: Qt.AlignHCenter
                text: "OÙ EST POSÉ LE ROBOT ?"
                color: root.palette.textSec
                font.pixelSize: 11
                font.letterSpacing: 1
                font.weight: Font.Medium
            }

            ListView {
                id: zoneList
                Layout.fillWidth: true
                Layout.preferredHeight: 140
                spacing: 6
                clip: true
                model: preMatch.zones

                delegate: Rectangle {
                    readonly property bool selected: modelData.name === preMatch.selectedZone
                    width: zoneList.width; height: 40
                    radius: 8
                    color:        selected ? "#14532d" : root.palette.surface
                    border.color: selected ? root.palette.green : root.palette.border
                    border.width: selected ? 2 : 1

                    Text {
                        anchors.centerIn: parent
                        text:  modelData.label
                        color: selected ? "#dcfce7" : root.palette.textPri
                        font.pixelSize: 14
                        font.weight: Font.DemiBold
                    }
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: preMatch.selectZone(modelData.name)
                    }
                }

                Text {
                    anchors.centerIn: parent
                    width: parent.width
                    visible: zoneList.count === 0
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignHCenter
                    text:  "Aucune zone reçue du robot"
                    color: root.palette.textSec
                    font.pixelSize: 13
                    font.italic: true
                }
            }

            // Where to put the robot
            Text {
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                visible: root.zone !== null
                text: root.zone === null ? "" :
                      "x " + root.zone.x.toFixed(2) + "   y " + root.zone.y.toFixed(2)
                      + "   cap " + Math.round(root.zone.theta * 180 / Math.PI) + "°"
                color: root.palette.textSec
                font.pixelSize: 12
                font.family: "Monospace"
            }

            RecalageButton {
                palette: root.palette
                Layout.fillWidth: true
                Layout.preferredHeight: 52
            }

            // Refusal of the robot, full failure (cut in the banner), or wrong zones in its file
            Text {
                Layout.fillWidth:  true
                Layout.fillHeight: true
                wrapMode: Text.WordWrap
                elide: Text.ElideRight
                horizontalAlignment: Text.AlignHCenter
                readonly property string problem: preMatch.message !== "" ? preMatch.message
                                                : preMatch.bannerKind === "error" ? preMatch.bannerText : ""
                text:  problem !== "" ? problem : preMatch.zoneErrors.join("\n")
                color: problem !== "" ? "#fca5a5" : "#fcd34d"
                font.pixelSize: 12
            }
        }
    }
}

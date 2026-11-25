import QtQuick

// Starts the recalage of the selected zone (with or without the tirette)
Rectangle {
    id: root

    required property var palette
    readonly property bool active: preMatch.canRecalage && preMatch.selectedZone !== ""

    radius: 10
    color: !active             ? root.palette.surface
         : area.pressed        ? "#1e3a5f"
         : "#1e3a8a"
    border.color: active ? root.palette.accent : root.palette.border
    border.width: 1

    Text {
        anchors.centerIn: parent
        text:  "LANCER LE RECALAGE"
        color: root.active ? "#dbeafe" : root.palette.textSec
        font.pixelSize:     12
        font.weight:        Font.DemiBold
        font.letterSpacing: 1
    }
    MouseArea {
        id: area
        anchors.fill: parent
        enabled:      root.active
        cursorShape:  Qt.PointingHandCursor
        onClicked:    preMatch.startRecalage()
    }
}

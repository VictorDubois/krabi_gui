import QtQuick
import QtQuick.Controls

Rectangle {
    id: root

    required property var    pageNames
    required property int    currentIndex
    signal tabClicked(int index)

    color: "#181c28"

    // Bottom separator
    Rectangle {
        anchors.bottom: parent.bottom
        width: parent.width
        height: 1
        color: "#2c3354"
    }

    // Sliding accent underline
    Rectangle {
        id: indicator
        height: 2
        width:  parent.width / root.pageNames.length
        color:  "#3b82f6"
        anchors.bottom: parent.bottom

        Behavior on x { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }
        x: root.currentIndex * width
    }

    Row {
        anchors.fill: parent

        Repeater {
            model: root.pageNames

            Item {
                width:  root.width / root.pageNames.length
                height: root.height

                readonly property bool active: root.currentIndex === index

                Text {
                    anchors.centerIn: parent
                    text:            modelData
                    font.pixelSize:  13
                    font.weight:     parent.active ? Font.DemiBold : Font.Normal
                    font.family:     "Sans Serif"
                    color:           parent.active ? "#3b82f6" : "#64748b"

                    Behavior on color { ColorAnimation { duration: 150 } }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape:  Qt.PointingHandCursor
                    onClicked:    root.tabClicked(index)
                }
            }
        }
    }
}

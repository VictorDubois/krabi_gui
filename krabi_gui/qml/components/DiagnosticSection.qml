import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root
    required property var palette
    property string title: ""
    default property alias items: itemsColumn.children

    color:        root.palette.surface
    radius:       10
    border.color: root.palette.border
    border.width: 1

    ColumnLayout {
        anchors { fill: parent; margins: 16 }
        spacing: 0

        // Section title
        Text {
            Layout.alignment: Qt.AlignHCenter
            text: root.title
            color: root.palette.textPri
            font.pixelSize: 14
            font.weight: Font.DemiBold
            font.letterSpacing: 1
        }

        // Divider
        Rectangle {
            Layout.fillWidth: true
            Layout.topMargin: 10
            Layout.bottomMargin: 10
            height: 1
            color: root.palette.border
        }

        // Items placed here as direct children
        ColumnLayout {
            id: itemsColumn
            Layout.fillWidth: true
            spacing: 0
        }

        Item { Layout.fillHeight: true }
    }
}

import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root
    required property var    palette
    property string title: ""
    property var    items:  []

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

        // Items
        Repeater {
            model: root.items
            DiagnosticItem {
                Layout.fillWidth: true
                palette: root.palette
                name:    modelData.name
                status:  modelData.status
            }
        }

        Item { Layout.fillHeight: true }
    }
}

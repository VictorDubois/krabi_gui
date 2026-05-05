import QtQuick
import QtQuick.Layouts

Item {
    id: root
    required property var    palette
    property string name:    ""
    property bool   status:  true
    property bool   warning: false  // true = WARN level (orange), only when status is false
    property string value:   ""     // when set, shown instead of OK / KO / WARN

    implicitHeight: 36

    RowLayout {
        anchors { fill: parent; leftMargin: 4; rightMargin: 4 }
        spacing: 10

        // Status LED
        Rectangle {
            width: 10; height: 10; radius: 5
            color: root.status ? "#22c55e" : (root.warning ? "#f59e0b" : "#ef4444")

            // Subtle glow
            Rectangle {
                anchors.centerIn: parent
                width: 18; height: 18; radius: 9
                color: root.status ? "#22c55e" : (root.warning ? "#f59e0b" : "#ef4444")
                opacity: 0.20
            }

            Behavior on color { ColorAnimation { duration: 300 } }
        }

        Text {
            Layout.fillWidth: true
            text:  root.name
            color: root.palette.textPri
            font.pixelSize: 13
        }

        Text {
            text:  root.value !== "" ? root.value
                                     : (root.status ? "OK" : (root.warning ? "WARN" : "KO"))
            color: root.status ? "#22c55e" : (root.warning ? "#f59e0b" : "#ef4444")
            font.pixelSize: 12
            font.weight: Font.DemiBold
            font.family: "Monospace"
            Behavior on color { ColorAnimation { duration: 300 } }
        }
    }
}

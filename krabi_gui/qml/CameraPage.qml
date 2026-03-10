import QtQuick
import QtQuick.Controls

Item {
    id: root
    required property var palette

    Rectangle { anchors.fill: parent; color: "#000000" }

    // Live camera feed
    Image {
        id: feed
        anchors.fill: parent
        source:       camera.hasFrame ? camera.frameUrl : ""
        fillMode:     Image.PreserveAspectFit
        cache:        false
        asynchronous: true
        smooth:       true
    }

    // "No signal" overlay — shown until first frame arrives
    Rectangle {
        anchors.centerIn: parent
        visible:  !camera.hasFrame
        width:    220; height: 80
        radius:   12
        color:    "#1a1a2e"
        border.color: "#2c3354"
        border.width: 1

        Column {
            anchors.centerIn: parent
            spacing: 6

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Pas de signal"
                color: "#64748b"
                font.pixelSize: 15
                font.weight: Font.Medium
            }
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "/krabi_ns/krabi_cam_raw"
                color: "#374151"
                font.pixelSize: 11
                font.family: "Monospace"
            }
        }
    }

    // Topic badge (bottom-right)
    Rectangle {
        anchors { right: parent.right; bottom: parent.bottom; margins: 10 }
        visible: camera.hasFrame
        height: 22
        width: topicLabel.implicitWidth + 16
        radius: 4
        color: "#111827cc"

        Text {
            id: topicLabel
            anchors.centerIn: parent
            text: "/krabi_ns/krabi_cam_raw"
            color: "#6b7280"
            font.pixelSize: 10
            font.family: "Monospace"
        }
    }
}

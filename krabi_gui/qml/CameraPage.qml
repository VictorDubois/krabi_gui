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
        width:    240; height: 80
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
                text: pageController.cameraTopicName
                color: "#374151"
                font.pixelSize: 11
                font.family: "Monospace"
            }
        }
    }

    // ── Camera source toggle (bottom-right) ────────────────────────────────
    Rectangle {
        anchors { right: parent.right; bottom: parent.bottom; margins: 10 }
        height: 28
        width:  switchLabel.implicitWidth + 28
        radius: 6
        color:        pageController.debugCamera ? "#1e2d40" : "#111827cc"
        border.color: pageController.debugCamera ? "#3b82f6" : "#374151"
        border.width: 1
        Behavior on color        { ColorAnimation { duration: 150 } }
        Behavior on border.color { ColorAnimation { duration: 150 } }

        Text {
            id: switchLabel
            anchors.centerIn: parent
            text:  pageController.debugCamera ? "DEBUG" : "MAIN"
            color: pageController.debugCamera ? "#93c5fd" : "#6b7280"
            font.pixelSize: 11; font.family: "Monospace"; font.weight: Font.Bold
            Behavior on color { ColorAnimation { duration: 150 } }
        }
        MouseArea {
            anchors.fill: parent; cursorShape: Qt.PointingHandCursor
            onClicked: pageController.toggleCamera()
        }
    }
}

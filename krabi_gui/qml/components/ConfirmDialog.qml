import QtQuick

// Modal confirmation: title, optional detail, ANNULER / confirm
Rectangle {
    id: root

    required property var palette
    property string title:       ""
    property string detail:      ""
    property string confirmText: ""
    property color  accent:      "#ef4444"
    property color  accentBg:    "#1f0e0e"
    property color  accentText:  "#fca5a5"
    signal confirmed()

    anchors.fill: parent
    color:   "#b0000000"
    visible: false
    z:       10

    // Nothing behind the dialog can be clicked
    MouseArea { anchors.fill: parent }

    Rectangle {
        anchors.centerIn: parent
        width:  380
        height: column.height + 48
        radius: 16
        color:        root.palette.surface
        border.color: root.accent
        border.width: 2

        Column {
            id: column
            anchors.centerIn: parent
            spacing: 18

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text:               root.title
                color:              root.palette.textPri
                font.pixelSize:     16
                font.weight:        Font.Bold
                font.letterSpacing: 1
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                visible: text !== ""
                width:   330
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
                text:  root.detail
                color: root.palette.textPri
                font.pixelSize: 13
            }

            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 16

                Rectangle {
                    width: 140; height: 48
                    radius:       10
                    color:        cancelArea.pressed ? root.palette.surface2 : root.palette.surface
                    border.color: root.palette.border
                    border.width: 1

                    Text {
                        anchors.centerIn: parent
                        text:        "ANNULER"
                        color:       root.palette.textPri
                        font.pixelSize: 13
                        font.weight:    Font.DemiBold
                    }
                    MouseArea {
                        id: cancelArea
                        anchors.fill: parent
                        cursorShape:  Qt.PointingHandCursor
                        onClicked:    root.visible = false
                    }
                }

                Rectangle {
                    width: 140; height: 48
                    radius:       10
                    color:        confirmArea.pressed ? root.palette.surface2 : root.accentBg
                    border.color: root.accent
                    border.width: 1

                    Text {
                        anchors.centerIn: parent
                        text:        root.confirmText
                        color:       root.accentText
                        font.pixelSize: 13
                        font.weight:    Font.DemiBold
                    }
                    MouseArea {
                        id: confirmArea
                        anchors.fill: parent
                        cursorShape:  Qt.PointingHandCursor
                        onClicked: {
                            root.visible = false
                            root.confirmed()
                        }
                    }
                }
            }
        }
    }
}

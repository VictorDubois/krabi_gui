import QtQuick

// State of the robot, on every page. Not clickable, never blocks navigation.
// Rules: banner.py
Rectangle {
    id: root
    height: 30

    readonly property var styles: ({
        "grey":  { bg: "#1f2430", fg: "#94a3b8", line: "#374151" },
        "wait":  { bg: "#facc15", fg: "#1a1000", line: "#facc15" },
        "busy":  { bg: "#1e3a8a", fg: "#dbeafe", line: "#3b82f6" },
        "ready": { bg: "#15803d", fg: "#f0fdf4", line: "#22c55e" },
        "error": { bg: "#991b1b", fg: "#fef2f2", line: "#ef4444" },
        "match": { bg: "#181c28", fg: "#86efac", line: "#22c55e" },
        "end":   { bg: "#422006", fg: "#fcd34d", line: "#f59e0b" }
    })
    readonly property var  style:    styles[preMatch.bannerKind]
    readonly property bool blinking: preMatch.bannerKind === "wait"
    property bool lit: true

    // Blinks the background only: the text stays readable
    color: blinking && !lit ? "#422006" : style.bg

    Timer {
        interval: 500
        running:  root.blinking
        repeat:   true
        onTriggered: root.lit = !root.lit
        onRunningChanged: root.lit = true
    }

    Rectangle {
        anchors.bottom: parent.bottom
        width: parent.width; height: 1
        color: root.style.line
    }

    Text {
        anchors.fill: parent
        anchors.leftMargin: 12; anchors.rightMargin: 12
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment:   Text.AlignVCenter
        text:  preMatch.bannerText
        color: root.blinking && !root.lit ? "#facc15" : root.style.fg
        elide: Text.ElideRight
        font.pixelSize: 14
        font.weight: Font.Bold
        font.letterSpacing: 1
    }
}

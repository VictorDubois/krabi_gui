import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root
    required property var palette

    // Field: 3 m (X, horizontal) × 2 m (Y, vertical), origin at centre of table
    // Robot frame: X positive = left, Y positive = bottom, 0° pointing towards bottom
    // Mapping: screenX = ox + (fieldW/2 - robotX) * scale
    //          screenY = oy + (fieldH/2 + robotY) * scale
    readonly property real fieldW: 3.0
    readonly property real fieldH: 2.0

    property bool showMap:  true
    property bool showGrid: true

    Rectangle { anchors.fill: parent; color: root.palette.bg }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // ── Canvas ─────────────────────────────────────────────────────
        Canvas {
            id: canvas
            Layout.fillWidth:  true
            Layout.fillHeight: true

            readonly property url tableUrl: Qt.resolvedUrl("../res/table.png")

            Component.onCompleted: loadImage(tableUrl)
            onImageLoaded: requestPaint()

            onWidthChanged:  requestPaint()
            onHeightChanged: requestPaint()

            Connections {
                target: robotStatus
                function onPoseChanged()      { canvas.requestPaint() }
                function onObstaclesChanged() { canvas.requestPaint() }
            }
            Connections {
                target: match
                function onTeamColorChanged() { canvas.requestPaint() }
            }

            onPaint: {
                var ctx = getContext("2d")
                ctx.clearRect(0, 0, width, height)

                var scale = Math.min(width / root.fieldW, height / root.fieldH)
                var ox    = (width  - root.fieldW * scale) / 2
                var oy    = (height - root.fieldH * scale) / 2
                var fw    = root.fieldW * scale
                var fh    = root.fieldH * scale

                // ── Table image / fallback ─────────────────────────────
                if (root.showMap && canvas.isImageLoaded(canvas.tableUrl)) {
                    ctx.drawImage(canvas.tableUrl, ox, oy, fw, fh)
                } else {
                    ctx.fillStyle = "#1a3a2a"
                    ctx.fillRect(ox, oy, fw, fh)
                }

                // Field border
                ctx.strokeStyle = "rgba(255,255,255,0.5)"
                ctx.lineWidth   = 2
                ctx.strokeRect(ox, oy, fw, fh)

                // ── Grid ──────────────────────────────────────────────
                if (root.showGrid) {
                    ctx.beginPath()
                    ctx.strokeStyle = "rgba(255,255,255,0.12)"
                    ctx.lineWidth   = 0.5
                    for (var yi = 1; yi < 30; yi++) {
                        var gx = ox + yi * 0.1 * scale
                        ctx.moveTo(gx, oy); ctx.lineTo(gx, oy + fh)
                    }
                    for (var xi = 1; xi < 20; xi++) {
                        var gy = oy + xi * 0.1 * scale
                        ctx.moveTo(ox, gy); ctx.lineTo(ox + fw, gy)
                    }
                    ctx.stroke()

                    // 50 cm lines
                    ctx.beginPath()
                    ctx.strokeStyle = "rgba(255,255,255,0.28)"
                    ctx.lineWidth   = 1
                    for (var yi5 = 1; yi5 < 6; yi5++) {
                        var gx5 = ox + yi5 * 0.5 * scale
                        ctx.moveTo(gx5, oy); ctx.lineTo(gx5, oy + fh)
                    }
                    for (var xi5 = 1; xi5 < 4; xi5++) {
                        var gy5 = oy + xi5 * 0.5 * scale
                        ctx.moveTo(ox, gy5); ctx.lineTo(ox + fw, gy5)
                    }
                    ctx.stroke()
                }

                // ── Robot ─────────────────────────────────────────────
                var rx     = robotStatus.robotX
                var ry     = robotStatus.robotY
                var theta  = robotStatus.robotAngle

                var sx = ox + (root.fieldW / 2 - rx) * scale
                var sy = oy + (root.fieldH / 2 + ry) * scale

                var size   = Math.max(14, scale * 0.11)
                var tcolor = match.teamColor === "blue" ? "#3b82f6" : "#f59e0b"

                ctx.save()
                ctx.translate(sx, sy)
                ctx.rotate(-theta)

                // Shadow
                ctx.shadowColor = "rgba(0,0,0,0.55)"
                ctx.shadowBlur  = 10

                // Body arrow — tip points left (0° = towards left of table)
                ctx.fillStyle   = tcolor
                ctx.strokeStyle = "#ffffff"
                ctx.lineWidth   = 1.5
                ctx.beginPath()
                ctx.moveTo(-size * 1.6,  0)
                ctx.lineTo( size * 0.8, -size)
                ctx.lineTo( size * 0.3,  0)
                ctx.lineTo( size * 0.8,  size)
                ctx.closePath()
                ctx.fill()
                ctx.stroke()

                ctx.shadowBlur = 0

                // Centre dot
                ctx.fillStyle = "#ffffff"
                ctx.beginPath()
                ctx.arc(0, 0, size * 0.18, 0, Math.PI * 2)
                ctx.fill()

                ctx.restore()

                // ── Obstacles ──────────────────────────────────────────
                var obsRadius = Math.max(8, scale * 0.075)
                var obstacles = [
                    { x: robotStatus.obstacleFrontX,  y: robotStatus.obstacleFrontY  },
                    { x: robotStatus.obstacleBehindX, y: robotStatus.obstacleBehindY }
                ]
                for (var oi = 0; oi < obstacles.length; oi++) {
                    var obs = obstacles[oi]
                    if (isNaN(obs.x) || isNaN(obs.y))
                        continue
                    var osx = ox + (root.fieldW / 2 - obs.x) * scale
                    var osy = oy + (root.fieldH / 2 + obs.y) * scale
                    ctx.save()
                    ctx.shadowColor = "rgba(0,0,0,0.55)"
                    ctx.shadowBlur  = 8
                    ctx.fillStyle   = "rgba(220,38,38,0.85)"
                    ctx.strokeStyle = "#ffffff"
                    ctx.lineWidth   = 1.5
                    ctx.beginPath()
                    ctx.arc(osx, osy, obsRadius, 0, Math.PI * 2)
                    ctx.fill()
                    ctx.stroke()
                    ctx.restore()
                }
            }
        }

        // ── Status bar ─────────────────────────────────────────────────
        Rectangle {
            Layout.fillWidth: true
            height: 44
            color: root.palette.surface

            Rectangle {
                anchors.top: parent.top; width: parent.width; height: 1
                color: root.palette.border
            }

            // Coordinates
            Row {
                anchors { left: parent.left; verticalCenter: parent.verticalCenter; leftMargin: 16 }
                spacing: 24

                Repeater {
                    model: [
                        { label: "X", value: robotStatus.robotX.toFixed(3) + " m" },
                        { label: "Y", value: robotStatus.robotY.toFixed(3) + " m" },
                        { label: "θ", value: (robotStatus.robotAngle * 180 / Math.PI).toFixed(1) + "°" }
                    ]
                    Row {
                        spacing: 4
                        Text {
                            text: modelData.label + ":"
                            color: root.palette.textSec
                            font.pixelSize: 12; font.family: "Monospace"
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        Text {
                            text: modelData.value
                            color: root.palette.textPri
                            font.pixelSize: 13; font.family: "Monospace"; font.weight: Font.Medium
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                }
            }

            // Toggle buttons
            Row {
                anchors { right: parent.right; verticalCenter: parent.verticalCenter; rightMargin: 12 }
                spacing: 8

                Rectangle {
                    width: 72; height: 28; radius: 6
                    color:        root.showMap ? "#1e2d40" : root.palette.bg
                    border.color: root.showMap ? root.palette.accent : root.palette.border
                    border.width: 1
                    Behavior on color        { ColorAnimation { duration: 120 } }
                    Behavior on border.color { ColorAnimation { duration: 120 } }
                    Text {
                        anchors.centerIn: parent
                        text:  "CARTE"
                        color: root.showMap ? root.palette.accent : root.palette.textSec
                        font.pixelSize: 11; font.family: "Monospace"; font.weight: Font.Medium
                        Behavior on color { ColorAnimation { duration: 120 } }
                    }
                    MouseArea {
                        anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                        onClicked: { root.showMap = !root.showMap; canvas.requestPaint() }
                    }
                }

                Rectangle {
                    width: 72; height: 28; radius: 6
                    color:        root.showGrid ? "#1e2d40" : root.palette.bg
                    border.color: root.showGrid ? root.palette.accent : root.palette.border
                    border.width: 1
                    Behavior on color        { ColorAnimation { duration: 120 } }
                    Behavior on border.color { ColorAnimation { duration: 120 } }
                    Text {
                        anchors.centerIn: parent
                        text:  "GRILLE"
                        color: root.showGrid ? root.palette.accent : root.palette.textSec
                        font.pixelSize: 11; font.family: "Monospace"; font.weight: Font.Medium
                        Behavior on color { ColorAnimation { duration: 120 } }
                    }
                    MouseArea {
                        anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                        onClicked: { root.showGrid = !root.showGrid; canvas.requestPaint() }
                    }
                }
            }
        }
    }
}

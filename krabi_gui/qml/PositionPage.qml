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

    // ── Game element groups ────────────────────────────────────────────
    // Positions: map-frame centres. X+ = left, Y+ = bottom.
    // "H" = long axis along X (150×50 mm), 4 rects stacked in Y.
    // "V" = long axis along Y (50×150 mm), 4 rects stacked in X.
    // Group 4 orientation assumed H (not specified in layout document).
    readonly property var groupDefs: [
        { x:  1.325, y: -0.20,  o: "H" },
        { x:  1.325, y:  0.60,  o: "H" },
        { x:  0.40, y:  0.825,  o: "V" },
        { x:  0.35, y:  0.2, o: "V" },
        { x: -1.325, y: -0.20,  o: "H" },
        { x: -1.325, y:  0.60,  o: "H" },
        { x: -0.40, y:  0.825,  o: "V" },
        { x: -0.35, y:  0.2, o: "V" }
    ]
    // 6 arrangements of 2 blue + 2 yellow (true = blue)
    readonly property var allConfigs: [
        [true,  true,  false, false],
        [true,  false, true,  false],
        [true,  false, false, true ],
        [false, true,  true,  false],
        [false, true,  false, true ],
        [false, false, true,  true ]
    ]
    property var  groupConfigs:  [0, 0, 0, 0, 0, 0, 0, 0]
    property int  selectedGroup: -1
    property real popupScreenX:   0
    property real popupScreenY:   0

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
            Connections {
                target: root
                function onGroupConfigsChanged()  { canvas.requestPaint() }
                function onSelectedGroupChanged() { canvas.requestPaint() }
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

                // ── Game element groups ────────────────────────────────
                for (var gi = 0; gi < root.groupDefs.length; gi++) {
                    var gdef       = root.groupDefs[gi]
                    var gcfg       = root.allConfigs[root.groupConfigs[gi]]
                    var isSelected = (gi === root.selectedGroup)

                    for (var ri = 0; ri < 4; ri++) {
                        var rcx, rcy, rhw, rhh
                        if (gdef.o === "H") {
                            // long axis along X, stacked in Y
                            rcx = gdef.x;                      rcy = gdef.y - 0.075 + ri * 0.05
                            rhw = 0.075;                       rhh = 0.025
                        } else {
                            // long axis along Y, stacked in X
                            rcx = gdef.x - 0.075 + ri * 0.05; rcy = gdef.y
                            rhw = 0.025;                       rhh = 0.075
                        }
                        var rsx = ox + (root.fieldW / 2 - rcx - rhw) * scale
                        var rsy = oy + (root.fieldH / 2 + rcy - rhh) * scale
                        var rsw = rhw * 2 * scale
                        var rsh = rhh * 2 * scale

                        ctx.fillStyle   = gcfg[ri] ? "#005b96" : "#f7b500"
                        ctx.strokeStyle = isSelected ? "#ffffff" : "rgba(255,255,255,0.45)"
                        ctx.lineWidth   = isSelected ? 1.5 : 0.5
                        ctx.fillRect(rsx, rsy, rsw, rsh)
                        ctx.strokeRect(rsx, rsy, rsw, rsh)
                    }
                }

                // ── Robot ─────────────────────────────────────────────
                var rx    = robotStatus.robotX
                var ry    = robotStatus.robotY
                var theta = robotStatus.robotAngle

                var sx = ox + (root.fieldW / 2 - rx) * scale
                var sy = oy + (root.fieldH / 2 + ry) * scale

                var size   = Math.max(14, scale * 0.11)
                var tcolor = match.teamColor === "blue" ? "#3b82f6" : "#f59e0b"

                ctx.save()
                ctx.translate(sx, sy)
                ctx.rotate(-theta)

                ctx.shadowColor = "rgba(0,0,0,0.55)"
                ctx.shadowBlur  = 10

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

            // ── Group click detection ──────────────────────────────────
            MouseArea {
                anchors.fill: parent
                enabled: root.selectedGroup < 0
                onClicked: function(mouse) {
                    var sc = Math.min(canvas.width / root.fieldW, canvas.height / root.fieldH)
                    var ox = (canvas.width  - root.fieldW * sc) / 2
                    var oy = (canvas.height - root.fieldH * sc) / 2

                    var mapX = root.fieldW / 2 - (mouse.x - ox) / sc
                    var mapY = (mouse.y - oy) / sc - root.fieldH / 2

                    for (var gi = 0; gi < root.groupDefs.length; gi++) {
                        var g  = root.groupDefs[gi]
                        var hw = g.o === "H" ? 0.075 : 0.10
                        var hh = g.o === "H" ? 0.10  : 0.075
                        if (Math.abs(mapX - g.x) <= hw && Math.abs(mapY - g.y) <= hh) {
                            root.selectedGroup = gi
                            root.popupScreenX  = mouse.x
                            root.popupScreenY  = mouse.y
                            break
                        }
                    }
                }
            }

            // Backdrop — closes popup when clicking outside it
            MouseArea {
                anchors.fill: parent
                visible: root.selectedGroup >= 0
                z: 9
                onClicked: root.selectedGroup = -1
            }

            // ── Config picker popup ────────────────────────────────────
            Rectangle {
                id: configPopup
                visible: root.selectedGroup >= 0
                z: 10

                readonly property int cardSize: 54
                readonly property int gap:      6
                readonly property int pad:      10
                readonly property int cols:     3

                width:  cols * cardSize + (cols - 1) * gap + 2 * pad
                height: 2 * cardSize + gap + 2 * pad + 22   // 22 for title row

                x: {
                    var px = root.popupScreenX - width / 2
                    return Math.max(4, Math.min(px, canvas.width  - width  - 4))
                }
                y: {
                    var py = root.popupScreenY - height - 12
                    if (py < 4) py = root.popupScreenY + 12
                    return Math.max(4, Math.min(py, canvas.height - height - 4))
                }

                radius: 8
                color:  "#0f1117"
                border.color: "#374151"
                border.width: 1

                // Consume all clicks so they don't reach the backdrop
                MouseArea { anchors.fill: parent }

                Column {
                    anchors { fill: parent; margins: configPopup.pad }
                    spacing: configPopup.gap

                    Text {
                        text: "Configuration"
                        color: "#9ca3af"
                        font.pixelSize: 11; font.family: "Monospace"
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    Grid {
                        columns: configPopup.cols
                        spacing: configPopup.gap
                        anchors.horizontalCenter: parent.horizontalCenter

                        Repeater {
                            model: 6
                            delegate: Rectangle {
                                property int cfgIdx: index

                                width:  configPopup.cardSize
                                height: configPopup.cardSize
                                radius: 5

                                color: root.selectedGroup >= 0
                                       && root.groupConfigs[root.selectedGroup] === cfgIdx
                                       ? "#1e3a5f" : "#1f2937"
                                border.color: root.selectedGroup >= 0
                                              && root.groupConfigs[root.selectedGroup] === cfgIdx
                                              ? "#60a5fa" : "#374151"
                                border.width: root.selectedGroup >= 0
                                              && root.groupConfigs[root.selectedGroup] === cfgIdx
                                              ? 2 : 1

                                // Mini colour preview
                                Item {
                                    anchors.centerIn: parent
                                    readonly property bool isH: root.selectedGroup >= 0
                                                                ? root.groupDefs[root.selectedGroup].o === "H"
                                                                : true
                                    readonly property int mLong:  32
                                    readonly property int mShort: 7
                                    readonly property int mGap:   2

                                    width:  isH ? mLong  : 4 * mShort + 3 * mGap
                                    height: isH ? 4 * mShort + 3 * mGap : mLong

                                    Repeater {
                                        model: 4
                                        delegate: Rectangle {
                                            property int ri: index
                                            x: parent.isH ? 0 : ri * (parent.mShort + parent.mGap)
                                            y: parent.isH ? ri * (parent.mShort + parent.mGap) : 0
                                            width:  parent.isH ? parent.mLong  : parent.mShort
                                            height: parent.isH ? parent.mShort : parent.mLong
                                            color:  root.allConfigs[cfgIdx][ri] ? "#005b96" : "#f7b500"
                                        }
                                    }
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        var nc = root.groupConfigs.slice()
                                        nc[root.selectedGroup] = cfgIdx
                                        root.groupConfigs = nc
                                        root.selectedGroup = -1
                                    }
                                }
                            }
                        }
                    }
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

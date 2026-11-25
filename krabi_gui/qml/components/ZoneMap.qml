import QtQuick

// Table seen from above (same view as the Carte page), with the recalage zones of the robot.
// Click on a zone to select it. Field: X+ to the left, Y+ to the bottom.
Item {
    id: root

    readonly property real fieldW: 3.0
    readonly property real fieldH: 2.0
    readonly property real zoneRadius: 0.13  // m

    // Crates at the start of the match (same as the Carte page)
    readonly property var groupDefs: [
        { x:  1.325, y: -0.20, o: "H" }, { x:  1.325, y: 0.60, o: "H" },
        { x:  0.40,  y: 0.825, o: "V" }, { x:  0.35,  y: 0.2,  o: "V" },
        { x: -1.325, y: -0.20, o: "H" }, { x: -1.325, y: 0.60, o: "H" },
        { x: -0.40,  y: 0.825, o: "V" }, { x: -0.35,  y: 0.2,  o: "V" }
    ]

    function geometry() {
        var scale = Math.min(width / fieldW, height / fieldH)
        return { scale: scale, ox: (width - fieldW * scale) / 2, oy: (height - fieldH * scale) / 2 }
    }
    function toScreen(g, x, y) {
        return { x: g.ox + (fieldW / 2 - x) * g.scale, y: g.oy + (fieldH / 2 + y) * g.scale }
    }

    // ── Table and crates ───────────────────────────────────────────────────
    Canvas {
        id: tableCanvas
        anchors.fill: parent
        readonly property url tableUrl: Qt.resolvedUrl("../../res/table.png")

        Component.onCompleted: loadImage(tableUrl)
        onImageLoaded:   requestPaint()
        onWidthChanged:  requestPaint()
        onHeightChanged: requestPaint()

        onPaint: {
            var ctx = getContext("2d")
            ctx.clearRect(0, 0, width, height)
            var g = root.geometry()
            var fw = root.fieldW * g.scale, fh = root.fieldH * g.scale

            if (isImageLoaded(tableUrl)) {
                ctx.drawImage(tableUrl, g.ox, g.oy, fw, fh)
            } else {
                ctx.fillStyle = "#1a3a2a"
                ctx.fillRect(g.ox, g.oy, fw, fh)
            }
            ctx.strokeStyle = "rgba(255,255,255,0.5)"
            ctx.lineWidth = 2
            ctx.strokeRect(g.ox, g.oy, fw, fh)

            for (var gi = 0; gi < root.groupDefs.length; gi++) {
                var d = root.groupDefs[gi]
                var hw = d.o === "H" ? 0.075 : 0.10, hh = d.o === "H" ? 0.10 : 0.075
                var p = root.toScreen(g, d.x + hw, d.y - hh)
                ctx.fillStyle = "rgba(15,17,23,0.55)"
                ctx.strokeStyle = "rgba(255,255,255,0.7)"
                ctx.lineWidth = 1
                ctx.fillRect(p.x, p.y, 2 * hw * g.scale, 2 * hh * g.scale)
                ctx.strokeRect(p.x, p.y, 2 * hw * g.scale, 2 * hh * g.scale)
            }
        }
    }

    // ── Zones and robot ────────────────────────────────────────────────────
    Canvas {
        id: zoneCanvas
        anchors.fill: parent
        onWidthChanged:  requestPaint()
        onHeightChanged: requestPaint()

        Connections {
            target: preMatch
            function onZonesChanged()        { zoneCanvas.requestPaint() }
            function onSelectedZoneChanged() { zoneCanvas.requestPaint() }
        }
        Connections {
            target: robotStatus
            function onPoseChanged() { zoneCanvas.requestPaint() }
        }

        // Front of the robot at -x, as on the Carte page
        function arrow(ctx, r, theta) {
            ctx.save()
            ctx.rotate(-theta)
            ctx.beginPath()
            ctx.moveTo(-r * 1.45, 0)
            ctx.lineTo(-r * 0.95, -r * 0.4)
            ctx.lineTo(-r * 0.95,  r * 0.4)
            ctx.closePath()
            ctx.fill()
            ctx.restore()
        }

        onPaint: {
            var ctx = getContext("2d")
            ctx.clearRect(0, 0, width, height)
            var g = root.geometry()
            var r = root.zoneRadius * g.scale
            var zones = preMatch.zones

            for (var zi = 0; zi < zones.length; zi++) {
                var zone = zones[zi]
                var selected = zone.name === preMatch.selectedZone
                var p = root.toScreen(g, zone.x, zone.y)

                ctx.save()
                ctx.translate(p.x, p.y)
                ctx.fillStyle   = selected ? "rgba(34,197,94,0.35)" : "rgba(15,17,23,0.45)"
                ctx.strokeStyle = selected ? "#22c55e" : "#ffffff"
                ctx.lineWidth   = selected ? 3 : 1.5
                ctx.beginPath()
                ctx.arc(0, 0, r, 0, Math.PI * 2)
                ctx.fill()
                ctx.stroke()
                ctx.fillStyle = selected ? "#22c55e" : "#ffffff"
                arrow(ctx, r, zone.theta)

                ctx.font         = "bold 12px sans-serif"
                ctx.textAlign    = "center"
                ctx.textBaseline = "middle"
                var tw = ctx.measureText(zone.label).width + 10
                var ty = zone.y > 0 ? -r - 16 : r + 16  // towards the centre: never cut
                ctx.fillStyle = "rgba(15,17,23,0.85)"
                ctx.fillRect(-tw / 2, ty - 9, tw, 18)
                ctx.fillStyle = selected ? "#86efac" : "#ffffff"
                ctx.fillText(zone.label, 0, ty)
                ctx.restore()
            }

            // Where the robot thinks it is
            var rp = root.toScreen(g, robotStatus.robotX, robotStatus.robotY)
            ctx.save()
            ctx.translate(rp.x, rp.y)
            ctx.fillStyle = match.teamColor === "blue" ? "#3b82f6" : "#f59e0b"
            ctx.strokeStyle = "#ffffff"
            ctx.lineWidth = 1.5
            ctx.beginPath()
            ctx.arc(0, 0, r * 0.55, 0, Math.PI * 2)
            ctx.fill()
            ctx.stroke()
            arrow(ctx, r * 0.55, robotStatus.robotAngle)
            ctx.restore()
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: function(mouse) {
            var g = root.geometry()
            var x = root.fieldW / 2 - (mouse.x - g.ox) / g.scale
            var y = (mouse.y - g.oy) / g.scale - root.fieldH / 2
            for (var zi = 0; zi < preMatch.zones.length; zi++) {
                var z = preMatch.zones[zi]
                if (Math.hypot(x - z.x, y - z.y) <= root.zoneRadius * 1.3) {
                    preMatch.selectZone(z.name)
                    return
                }
            }
        }
    }
}

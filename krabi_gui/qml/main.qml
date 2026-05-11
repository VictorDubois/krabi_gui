import QtQuick
import QtQuick.Controls
import "components"

ApplicationWindow {
    id: root
    visible: true
    width: 800
    height: 480
    title: "Krabi GUI"

    // ── Design tokens ──────────────────────────────────────────────────────
    readonly property color bg:        "#0f1117"
    readonly property color surface:   "#181c28"
    readonly property color surface2:  "#1e2438"
    readonly property color border:    "#2c3354"
    readonly property color textPri:   "#e2e8f0"
    readonly property color textSec:   "#64748b"
    readonly property color accent:    "#3b82f6"
    readonly property color green:     "#22c55e"
    readonly property color red:       "#ef4444"
    readonly property color yellow:    "#f59e0b"

    background: Rectangle { color: root.bg }

    // ── Navigation bar ─────────────────────────────────────────────────────
    header: NavBar {
        id: navbar
        height: 44
        pageNames: ["Prépa", "Carte", "Diag", "Caméra", "Match"]
        currentIndex: swipeView.currentIndex
        onTabClicked: (idx) => swipeView.currentIndex = idx
    }

    // ── Pages ──────────────────────────────────────────────────────────────
    SwipeView {
        id: swipeView
        anchors.fill: parent
        currentIndex: 0
        clip: true
        onCurrentIndexChanged: pageController.onPageChanged(currentIndex)

        PreparationPage { palette: root }
        PositionPage    { palette: root }
        DiagnosticPage  { palette: root }
        CameraPage      { palette: root }
        ScorePage       { palette: root }
    }

    // ── Battery voltages overlay (bottom-right, all pages) ─────────────────
    Row {
        anchors.right:        parent.right
        anchors.bottom:       parent.bottom
        anchors.rightMargin:  10
        anchors.bottomMargin: 6
        spacing: 16
        z: 1

        Text {
            text:  isNaN(robotStatus.powerVoltage) ? "P: —V"
                   : "P: " + robotStatus.powerVoltage.toFixed(1) + "V"
            color: (!isNaN(robotStatus.powerVoltage) && robotStatus.powerPercentage >= 0.2)
                   ? root.green : root.red
            font.pixelSize:  12
            font.family:     "Monospace"
            font.weight:     Font.DemiBold
        }

        Text {
            text:  isNaN(robotStatus.elecVoltage) ? "E: —V"
                   : "E: " + robotStatus.elecVoltage.toFixed(1) + "V"
            color: (!isNaN(robotStatus.elecVoltage) && robotStatus.elecPercentage >= 0.2)
                   ? root.green : root.red
            font.pixelSize:  12
            font.family:     "Monospace"
            font.weight:     Font.DemiBold
        }
    }
}

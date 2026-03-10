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

        PreparationPage { palette: root }
        PositionPage    { palette: root }
        DiagnosticPage  { palette: root }
        CameraPage      { palette: root }
        ScorePage       { palette: root }
    }
}

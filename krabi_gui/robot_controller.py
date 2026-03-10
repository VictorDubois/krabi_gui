"""Robot controller aggregator.

This module keeps `RobotController` as a thin aggregator while the
concrete domain classes live in their own modules (`match.py`,
`robot_status.py`, `diagnostics.py`).
"""

from PySide6.QtCore import QObject, Property, Slot

# Import strategy: try absolute package imports first (recommended),
# then fall back to nearby-module imports so the module can be run in
# different contexts (script, package, or module).
try:
    from krabi_gui.match import Match
    from krabi_gui.robot_status import RobotStatus
    from krabi_gui.diagnostics import Diagnostics
except Exception:
    try:
        # If running from the package directory as a script
        from match import Match
        from robot_status import RobotStatus
        from diagnostics import Diagnostics
    except Exception:
        # Last resort: relative imports (works when executed as a package)
        from .match import Match
        from .robot_status import RobotStatus
        from .diagnostics import Diagnostics


class RobotController(QObject):
    """Aggregator that keeps sub-objects and preserves legacy API."""

    def __init__(self):
        super().__init__()
        self.match = Match(self)
        self.status = RobotStatus(self)
        self.diagnostics = Diagnostics(self)

    # Legacy compatibility methods/properties (so existing QML keeps working)
    @Property(str)
    def teamColor(self):
        return self.match.teamColor

    @Slot(str)
    def setTeamColor(self, color: str):
        self.match.setTeamColor(color)

    @Property(str)
    def strategy(self):
        return self.match.strategy

    @Slot(str)
    def setStrategy(self, strategy: str):
        self.match.setStrategy(strategy)

    @Property(float)
    def robotX(self):
        return self.status.robotX

    @Property(float)
    def robotY(self):
        return self.status.robotY

    @Property(float)
    def robotAngle(self):
        return self.status.robotAngle

    @Slot(float, float, float)
    def updatePosition(self, x: float, y: float, angle: float):
        self.status.updatePosition(x, y, angle)

    @Property(int)
    def score(self):
        return self.match.score

    @Property(int)
    def timeRemaining(self):
        return self.match.timeRemaining

    @Slot()
    def startMatch(self):
        self.match.start()

    @Slot()
    def stopMatch(self):
        self.match.stop()

    @Slot()
    def resetMatch(self):
        self.match.reset()

    @Slot(str, bool)
    def updateDiagnostic(self, key: str, status: bool):
        self.diagnostics.updateDiagnostic(key, status)


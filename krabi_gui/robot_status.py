"""Robot pose exposed to QML. Angle is stored in radians."""

from PySide6.QtCore import QObject, Signal, Property, Slot


class RobotStatus(QObject):
    poseChanged = Signal()

    def __init__(self, parent=None):
        super().__init__(parent)
        self._x     = 0.0
        self._y     = 0.0
        self._angle = 0.0  # radians

    @Property(float, notify=poseChanged)
    def robotX(self) -> float:
        return self._x

    @Property(float, notify=poseChanged)
    def robotY(self) -> float:
        return self._y

    @Property(float, notify=poseChanged)
    def robotAngle(self) -> float:
        return self._angle

    @Slot(float, float, float)
    def updatePosition(self, x: float, y: float, angle: float) -> None:
        self._x, self._y, self._angle = x, y, angle
        self.poseChanged.emit()

"""Robot pose exposed to QML. Angle is stored in radians."""

import math
from PySide6.QtCore import QObject, Signal, Property, Slot

_NAN = float('nan')


class RobotStatus(QObject):
    poseChanged      = Signal()
    obstaclesChanged = Signal()
    batteryChanged   = Signal()

    def __init__(self, parent=None):
        super().__init__(parent)
        self._x     = 0.0
        self._y     = 0.0
        self._angle = 0.0  # radians

        # NaN means "not yet received"
        self._obs_front_x  = _NAN
        self._obs_front_y  = _NAN
        self._obs_behind_x = _NAN
        self._obs_behind_y = _NAN

        self._power_voltage    = _NAN
        self._power_percentage = _NAN
        self._elec_voltage     = _NAN
        self._elec_percentage  = _NAN

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

    # ── Obstacle properties ──────────────────────────────────────────────

    @Property(float, notify=obstaclesChanged)
    def obstacleFrontX(self) -> float:
        return self._obs_front_x

    @Property(float, notify=obstaclesChanged)
    def obstacleFrontY(self) -> float:
        return self._obs_front_y

    @Property(float, notify=obstaclesChanged)
    def obstacleBehindX(self) -> float:
        return self._obs_behind_x

    @Property(float, notify=obstaclesChanged)
    def obstacleBehindY(self) -> float:
        return self._obs_behind_y

    @Slot(float, float)
    def updateObstacleFront(self, x: float, y: float) -> None:
        self._obs_front_x, self._obs_front_y = x, y
        self.obstaclesChanged.emit()

    @Slot(float, float)
    def updateObstacleBehind(self, x: float, y: float) -> None:
        self._obs_behind_x, self._obs_behind_y = x, y
        self.obstaclesChanged.emit()

    # ── Battery properties ───────────────────────────────────────────────

    @Property(float, notify=batteryChanged)
    def powerVoltage(self) -> float:
        return self._power_voltage

    @Property(float, notify=batteryChanged)
    def powerPercentage(self) -> float:
        return self._power_percentage

    @Property(float, notify=batteryChanged)
    def elecVoltage(self) -> float:
        return self._elec_voltage

    @Property(float, notify=batteryChanged)
    def elecPercentage(self) -> float:
        return self._elec_percentage

    @Slot(float, float)
    def updatePowerBattery(self, voltage: float, percentage: float) -> None:
        self._power_voltage, self._power_percentage = voltage, percentage
        self.batteryChanged.emit()

    @Slot(float, float)
    def updateElecBattery(self, voltage: float, percentage: float) -> None:
        self._elec_voltage, self._elec_percentage = voltage, percentage
        self.batteryChanged.emit()

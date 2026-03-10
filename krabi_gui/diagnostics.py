"""Static diagnostics status — will be driven by a ROS topic in a future sprint."""

from PySide6.QtCore import QObject, Signal, Property


class Diagnostics(QObject):
    # One signal per item keeps QML bindings granular
    lidarTopChanged      = Signal()
    lidarBottomChanged   = Signal()
    cameraChanged        = Signal()
    motorsCardChanged    = Signal()
    actuatorsCardChanged = Signal()
    canBusChanged        = Signal()
    wifiChanged          = Signal()
    dynamixelBusChanged  = Signal()

    def __init__(self, parent=None):
        super().__init__(parent)
        # Hardcoded until a ROS diagnostics topic is available
        self._lidar_top      = True
        self._lidar_bottom   = True
        self._camera         = True
        self._motors_card    = False   # KO
        self._actuators_card = True
        self._can_bus        = True
        self._wifi           = True
        self._dynamixel_bus  = False   # KO

    @Property(bool, notify=lidarTopChanged)
    def lidarTop(self) -> bool:
        return self._lidar_top

    @Property(bool, notify=lidarBottomChanged)
    def lidarBottom(self) -> bool:
        return self._lidar_bottom

    @Property(bool, notify=cameraChanged)
    def camera(self) -> bool:
        return self._camera

    @Property(bool, notify=motorsCardChanged)
    def motorsCard(self) -> bool:
        return self._motors_card

    @Property(bool, notify=actuatorsCardChanged)
    def actuatorsCard(self) -> bool:
        return self._actuators_card

    @Property(bool, notify=canBusChanged)
    def canBus(self) -> bool:
        return self._can_bus

    @Property(bool, notify=wifiChanged)
    def wifi(self) -> bool:
        return self._wifi

    @Property(bool, notify=dynamixelBusChanged)
    def dynamixelBus(self) -> bool:
        return self._dynamixel_bus

"""Pre-match state of the robot, recalage zones and restart, exposed to QML."""

import time

from PySide6.QtCore import QObject, QTimer, Qt, Signal, Property, Slot

try:
    from .banner import banner, can_recalage, can_restart
except ImportError:
    from banner import banner, can_recalage, can_restart

_SILENCE_S = 3.0   # the robot repeats its state at 1 Hz
_RESTART_S = 20.0  # no silence seen by then: the restart did not work, show the robot again


class PreMatch(QObject):
    bannerChanged = Signal()
    zonesChanged = Signal()
    selectedZoneChanged = Signal()
    messageChanged = Signal()

    recalageRequested = Signal(str)  # zone name
    restartRequested = Signal()

    # Emitted from the ROS thread, handled in the Qt thread
    stateReceived = Signal(str)
    zonesReceived = Signal('QVariantList', str, 'QVariantList')
    recalageAnswered = Signal(bool, str)

    def __init__(self, tirette, diagnostics, parent=None, clock=time.monotonic):
        super().__init__(parent)
        self._tirette = tirette
        self._diagnostics = diagnostics
        self._clock = clock
        self._state = ''
        self._last_state = None      # time of the last state received
        self._restart_at = None      # time of the restart, until the robot goes silent
        self._zones = []
        self._zone_errors = []
        self._default_zone = ''
        self._selected = ''
        self._message = ''
        self._banner = {}
        self._flags = ()

        self.stateReceived.connect(self._on_state, Qt.QueuedConnection)
        self.zonesReceived.connect(self._on_zones, Qt.QueuedConnection)
        self.recalageAnswered.connect(self._on_answer, Qt.QueuedConnection)
        tirette.insertedChanged.connect(self._refresh, Qt.QueuedConnection)
        diagnostics.rosItemsChanged.connect(self._refresh, Qt.QueuedConnection)

        self._timer = QTimer(self)
        self._timer.setInterval(500)
        self._timer.timeout.connect(self._refresh)
        self._timer.start()
        self._refresh()

    # ------------------------------------------------------------------
    # Properties
    # ------------------------------------------------------------------

    @Property(str, notify=bannerChanged)
    def bannerText(self) -> str:
        return self._banner['text']

    @Property(str, notify=bannerChanged)
    def bannerKind(self) -> str:
        return self._banner['kind']

    @Property(bool, notify=bannerChanged)
    def canRecalage(self) -> bool:
        return self._flags[0]

    @Property(bool, notify=bannerChanged)
    def canRestart(self) -> bool:
        return self._flags[1]

    @Property(bool, notify=bannerChanged)
    def restarting(self) -> bool:
        """RESTART COLOR asked, the old stack may still be talking: do not trust it."""
        return self._restart_at is not None

    @Property('QVariantList', notify=zonesChanged)
    def zones(self) -> list:
        """List of {name, label, x, y, theta}, for the colour of the robot."""
        return [] if self.restarting else self._zones

    @Property('QVariantList', notify=zonesChanged)
    def zoneErrors(self) -> list:
        return [] if self.restarting else self._zone_errors

    @Property(str, notify=selectedZoneChanged)
    def selectedZone(self) -> str:
        return self._selected

    @Property(str, notify=messageChanged)
    def message(self) -> str:
        """Last refusal of the robot, empty if none."""
        return self._message

    # ------------------------------------------------------------------
    # Slots callable from QML
    # ------------------------------------------------------------------

    @Slot(str)
    def selectZone(self, name: str) -> None:
        if name != self._selected:
            self._selected = name
            self.selectedZoneChanged.emit()

    @Slot()
    def startRecalage(self) -> None:
        if self.canRecalage and self._selected:
            self._set_message('')
            self.recalageRequested.emit(self._selected)

    @Slot()
    def restart(self) -> None:
        """RESTART COLOR: new ROS stack, so forget everything the old one said."""
        if not self.canRestart:
            return
        self._restart_at = self._clock()
        self._state = ''
        self.zonesChanged.emit()
        self.selectZone('')
        self._set_message('')
        self._refresh()
        self.restartRequested.emit()

    # ------------------------------------------------------------------
    # Qt thread
    # ------------------------------------------------------------------

    def _alive(self) -> bool:
        return (self._restart_at is None and self._last_state is not None
                and self._clock() - self._last_state < _SILENCE_S)

    @Slot(str)
    def _on_state(self, state: str) -> None:
        now = self._clock()
        if self._restart_at is not None:
            # Until it goes silent, this is still the old stack talking
            silent = self._last_state is None or now - self._last_state >= _SILENCE_S
            if silent or now - self._restart_at > _RESTART_S:
                self._restart_at = None
                self.zonesChanged.emit()
                self.selectZone(self._default_zone)
        self._last_state = now
        if self._restart_at is None:
            if state != self._state:
                self._set_message('')
            self._state = state
        self._refresh()

    @Slot('QVariantList', str, 'QVariantList')
    def _on_zones(self, zones: list, default_zone: str, errors: list) -> None:
        self._zones, self._zone_errors = zones, errors
        self._default_zone = default_zone
        self.zonesChanged.emit()
        if not self.restarting and self._selected not in [z['name'] for z in zones]:
            self.selectZone(default_zone)

    @Slot(bool, str)
    def _on_answer(self, success: bool, message: str) -> None:
        self._set_message('' if success else message)

    def _set_message(self, message: str) -> None:
        if message != self._message:
            self._message = message
            self.messageChanged.emit()

    @Slot()
    def _refresh(self) -> None:
        errors = [f"{i['name']} : {i['message']}" for i in self._diagnostics.rosItems
                  if not i['ok'] and not i['warning']]
        alive = self._alive()
        new = banner(alive, self._state, self._tirette.inserted, errors)
        flags = (can_recalage(alive, self._state), can_restart(alive, self._state),
                 self.restarting)
        if (new, flags) != (self._banner, self._flags):
            self._banner, self._flags = new, flags
            self.bannerChanged.emit()

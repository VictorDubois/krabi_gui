"""Match state exposed to QML."""

from PySide6.QtCore import QObject, Signal, Property, Slot


class Match(QObject):
    teamColorChanged     = Signal()
    scoreChanged         = Signal()
    strategyStepChanged  = Signal()
    timeRemainingChanged = Signal()
    recalageRequested    = Signal()

    def __init__(self, parent=None):
        super().__init__(parent)
        self._team_color     = 'blue'
        self._score          = 0
        self._time_remaining = 100
        self._strategy_step  = ''

    # ------------------------------------------------------------------
    # Properties
    # ------------------------------------------------------------------

    @Property(str, notify=teamColorChanged)
    def teamColor(self) -> str:
        return self._team_color

    @Property(int, notify=scoreChanged)
    def score(self) -> int:
        return self._score

    @Property(int, notify=timeRemainingChanged)
    def timeRemaining(self) -> int:
        return self._time_remaining

    @Property(str, notify=strategyStepChanged)
    def strategyStep(self) -> str:
        return self._strategy_step

    # ------------------------------------------------------------------
    # Slots callable from QML and ROS node
    # ------------------------------------------------------------------

    @Slot(str)
    def setTeamColor(self, color: str) -> None:
        if self._team_color != color:
            self._team_color = color
            self.teamColorChanged.emit()

    @Slot(int)
    def setTimeRemaining(self, sec: int) -> None:
        if self._time_remaining != sec:
            self._time_remaining = sec
            self.timeRemainingChanged.emit()

    @Slot(int)
    def setScore(self, score: int) -> None:
        if self._score != score:
            self._score = score
            self.scoreChanged.emit()

    @Slot(str)
    def setStrategyStep(self, step: str) -> None:
        step = step or ''
        if self._strategy_step != step:
            self._strategy_step = step
            self.strategyStepChanged.emit()

    @Slot()
    def triggerRecalage(self) -> None:
        self.recalageRequested.emit()

    @Slot()
    def start(self) -> None:
        pass  # TODO: publish match start to ROS

    @Slot()
    def stop(self) -> None:
        pass  # TODO: publish match stop to ROS

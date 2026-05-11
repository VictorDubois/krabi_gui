"""Tirette presence state exposed to QML."""

from PySide6.QtCore import QObject, Signal, Property, Slot


class Tirette(QObject):
    insertedChanged = Signal()

    def __init__(self, parent=None):
        super().__init__(parent)
        self._inserted = False

    @Property(bool, notify=insertedChanged)
    def inserted(self) -> bool:
        return self._inserted

    @Slot(bool)
    def updateInserted(self, value: bool) -> None:
        if self._inserted != value:
            self._inserted = not value # Tirette GO = tirette is not inserted
            self.insertedChanged.emit()

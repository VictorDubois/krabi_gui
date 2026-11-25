"""Tirette presence state exposed to QML."""

from PySide6.QtCore import QObject, Signal, Property, Slot


class Tirette(QObject):
    insertedChanged = Signal()

    def __init__(self, parent=None):
        super().__init__(parent)
        self._inserted = False
        self._known = False  # False until the robot says something

    @Property(bool, notify=insertedChanged)
    def inserted(self) -> bool:
        return self._inserted

    @Property(bool, notify=insertedChanged)
    def known(self) -> bool:
        return self._known

    @Slot(bool)
    def updateRemoved(self, removed: bool) -> None:
        """Update from the /krabi_ns/tirette topic: True = tirette removed = GO."""
        if not self._known or self._inserted == removed:
            self._known, self._inserted = True, not removed
            self.insertedChanged.emit()

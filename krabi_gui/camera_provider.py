"""Camera image provider: bridges ROS sensor_msgs/Image to QML."""

import threading

from PySide6.QtCore import QObject, Signal, Property, QSize
from PySide6.QtGui import QImage
from PySide6.QtQuick import QQuickImageProvider


# ---------------------------------------------------------------------------
# Conversion helper
# ---------------------------------------------------------------------------

def _ros_image_to_qimage(msg) -> QImage:
    enc = msg.encoding.lower()
    data = bytes(msg.data)
    w, h, step = msg.width, msg.height, msg.step

    _FMT = {
        'rgb8':  QImage.Format.Format_RGB888,
        'bgr8':  QImage.Format.Format_BGR888,
        'rgba8': QImage.Format.Format_RGBA8888,
        'bgra8': QImage.Format.Format_ARGB32,
        'mono8': QImage.Format.Format_Grayscale8,
        '8uc1':  QImage.Format.Format_Grayscale8,
    }
    fmt = _FMT.get(enc, QImage.Format.Format_RGB888)
    return QImage(data, w, h, step, fmt).copy()


# ---------------------------------------------------------------------------
# QQuickImageProvider — stores the latest frame for QML to pull
# ---------------------------------------------------------------------------

class CameraProvider(QQuickImageProvider):
    def __init__(self):
        super().__init__(QQuickImageProvider.ImageType.Image)
        self._lock = threading.Lock()
        self._image = QImage(640, 480, QImage.Format.Format_RGB888)
        self._image.fill(0)

    def update_image(self, qimage: QImage) -> None:
        with self._lock:
            self._image = qimage

    def requestImage(self, id: str, size: QSize, requestedSize: QSize) -> QImage:
        with self._lock:
            img = self._image.copy()
        size.setWidth(img.width())
        size.setHeight(img.height())
        return img


# ---------------------------------------------------------------------------
# Qt-side state object exposed to QML
# ---------------------------------------------------------------------------

class CameraState(QObject):
    frameChanged   = Signal()
    hasFrameChanged = Signal()

    def __init__(self, provider: CameraProvider, parent=None):
        super().__init__(parent)
        self._provider  = provider
        self._counter   = 0
        self._has_frame = False

    @Property(str, notify=frameChanged)
    def frameUrl(self) -> str:
        # Timestamp query param forces Qt image cache to reload on every update
        return f"image://camera/frame?t={self._counter}"

    @Property(bool, notify=hasFrameChanged)
    def hasFrame(self) -> bool:
        return self._has_frame

    def update_frame(self, ros_msg) -> None:
        """Called from the ROS background thread."""
        qimage = _ros_image_to_qimage(ros_msg)
        self._provider.update_image(qimage)
        self._counter += 1
        if not self._has_frame:
            self._has_frame = True
            self.hasFrameChanged.emit()
        self.frameChanged.emit()  # cross-thread signal → queued delivery on main thread

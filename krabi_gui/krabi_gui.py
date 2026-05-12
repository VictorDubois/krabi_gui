"""Krabi GUI — main entry point."""

import argparse
import signal
import sys
from pathlib import Path

from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine
from PySide6.QtCore import Property, QObject, Signal, Slot, QUrl, QTimer

try:
    from .match           import Match
    from .robot_status    import RobotStatus
    from .diagnostics     import Diagnostics
    from .camera_provider import CameraProvider, CameraState
    from .tirette         import Tirette
except ImportError as err:
    from match           import Match
    from robot_status    import RobotStatus
    from diagnostics     import Diagnostics
    from camera_provider import CameraProvider, CameraState
    from tirette         import Tirette


_MAIN_CAM  = '/krabi_ns/krabi_cam/image_raw'
_DEBUG_CAM = '/krabi_ns/debug_image'


class _PageController(QObject):
    """Bridges QML page navigation to ROS subscription management."""

    _CARTE_PAGE  = 1
    _CAMERA_PAGE = 3

    cameraTopicChanged = Signal()

    def __init__(self, node, parent=None):
        super().__init__(parent)
        self._node      = node
        self._debug_cam = False

    @Slot(int)
    def onPageChanged(self, index: int) -> None:
        if self._node is None:
            return
        if index == self._CAMERA_PAGE:
            self._node.enable_camera()
        else:
            self._node.disable_camera()
        if index == self._CARTE_PAGE:
            self._node.enable_tf()
        else:
            self._node.disable_tf()

    @Property(str, notify=cameraTopicChanged)
    def cameraTopicName(self) -> str:
        return _DEBUG_CAM if self._debug_cam else _MAIN_CAM

    @Property(bool, notify=cameraTopicChanged)
    def debugCamera(self) -> bool:
        return self._debug_cam

    @Slot()
    def toggleCamera(self) -> None:
        if self._node is None:
            return
        self._debug_cam = not self._debug_cam
        self._node.set_camera_topic(self.cameraTopicName)
        self.cameraTopicChanged.emit()


def main() -> int:
    parser = argparse.ArgumentParser(description='Krabi GUI')
    parser.add_argument('--simu', action='store_true',
                        help='Use simulation camera topic instead of real camera')
    parser.add_argument('--publish-tirette', action='store_true',
                        help='Publish team colour to /krabi_ns/is_blue (default: subscribe)')
    args, qt_args = parser.parse_known_args()

    app = QGuiApplication([sys.argv[0]] + qt_args)
    app.setApplicationName('Krabi GUI')

    # Allow Ctrl+C to quit: Qt blocks SIGINT by default, so we use a timer to
    # give Python a chance to process signals, and connect SIGINT to app.quit.
    signal.signal(signal.SIGINT, lambda *_: app.quit())
    timer = QTimer()
    timer.start(200)
    timer.timeout.connect(lambda: None)

    # Domain objects
    match         = Match()
    robot_status  = RobotStatus()
    diagnostics   = Diagnostics()
    cam_provider  = CameraProvider()
    camera        = CameraState(cam_provider)
    tirette       = Tirette()

    # Start ROS (non-fatal if unavailable)
    node = None
    try:
        try:
            from .ros_node import start_ros
        except ImportError:
            from ros_node import start_ros
        node = start_ros(robot_status, match, camera, tirette,
                         diagnostics=diagnostics,
                         publish_tirette=args.publish_tirette,
                         simu=args.simu)
    except Exception as exc:
        print(f'[krabi_gui] ROS unavailable — running in offline mode: {exc}',
              file=sys.stderr)

    if node is not None:
        match.recalageRequested.connect(node.publish_recalage)
        if args.publish_tirette:
            match.teamColorChanged.connect(
                lambda: node.publish_team(match.teamColor == 'blue')
            )

    page_ctrl = _PageController(node)

    engine = QQmlApplicationEngine()
    engine.addImageProvider('camera', cam_provider)

    ctx = engine.rootContext()
    ctx.setContextProperty('match',           match)
    ctx.setContextProperty('robotStatus',     robot_status)
    ctx.setContextProperty('diagnostics',     diagnostics)
    ctx.setContextProperty('camera',          camera)
    ctx.setContextProperty('tirette',         tirette)
    ctx.setContextProperty('pageController',  page_ctrl)

    qml_dir  = Path(__file__).parent / 'qml'
    qml_file = qml_dir / 'main.qml'
    engine.addImportPath(str(qml_dir))
    engine.load(QUrl.fromLocalFile(str(qml_file)))

    if not engine.rootObjects():
        return -1

    # Apply initial state: page 0 (Prépa) → camera + TF both inactive
    page_ctrl.onPageChanged(0)

    return app.exec()


if __name__ == '__main__':
    sys.exit(main())

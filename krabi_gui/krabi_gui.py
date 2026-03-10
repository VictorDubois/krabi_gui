"""Krabi GUI — main entry point."""

import sys
from pathlib import Path

from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine
from PySide6.QtCore import QUrl

try:
    from .match           import Match
    from .robot_status    import RobotStatus
    from .diagnostics     import Diagnostics
    from .camera_provider import CameraProvider, CameraState
except ImportError:
    from match           import Match
    from robot_status    import RobotStatus
    from diagnostics     import Diagnostics
    from camera_provider import CameraProvider, CameraState


def main() -> int:
    app = QGuiApplication(sys.argv)
    app.setApplicationName('Krabi GUI')

    # Domain objects
    match         = Match()
    robot_status  = RobotStatus()
    diagnostics   = Diagnostics()
    cam_provider  = CameraProvider()
    camera        = CameraState(cam_provider)

    # Start ROS (non-fatal if unavailable)
    try:
        try:
            from .ros_node import start_ros
        except ImportError:
            from ros_node import start_ros
        start_ros(robot_status, match, camera)
    except Exception as exc:
        print(f'[krabi_gui] ROS unavailable — running in offline mode: {exc}',
              file=sys.stderr)

    engine = QQmlApplicationEngine()
    engine.addImageProvider('camera', cam_provider)

    ctx = engine.rootContext()
    ctx.setContextProperty('match',       match)
    ctx.setContextProperty('robotStatus', robot_status)
    ctx.setContextProperty('diagnostics', diagnostics)
    ctx.setContextProperty('camera',      camera)

    qml_dir  = Path(__file__).parent / 'qml'
    qml_file = qml_dir / 'main.qml'
    engine.addImportPath(str(qml_dir))
    engine.load(QUrl.fromLocalFile(str(qml_file)))

    if not engine.rootObjects():
        return -1

    return app.exec()


if __name__ == '__main__':
    sys.exit(main())

"""Krabi GUI — main entry point."""

import argparse
import signal
import sys
from pathlib import Path

from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine
from PySide6.QtCore import QUrl, QTimer

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


def main() -> int:
    parser = argparse.ArgumentParser(description='Krabi GUI')
    parser.add_argument('--simu', action='store_true',
                        help='Use simulation camera topic instead of real camera')
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
    try:
        try:
            from .ros_node import start_ros
        except ImportError:
            from ros_node import start_ros
        start_ros(robot_status, match, camera, tirette,
                  diagnostics=diagnostics, simu=args.simu)
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
    ctx.setContextProperty('tirette',     tirette)

    qml_dir  = Path(__file__).parent / 'qml'
    qml_file = qml_dir / 'main.qml'
    engine.addImportPath(str(qml_dir))
    engine.load(QUrl.fromLocalFile(str(qml_file)))

    if not engine.rootObjects():
        return -1

    return app.exec()


if __name__ == '__main__':
    sys.exit(main())

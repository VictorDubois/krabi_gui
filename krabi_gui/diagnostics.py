"""Live diagnostics: ROS DiagnosticArray + system checks for CAN and WiFi."""

import os
import re
import subprocess
import threading
import time

from PySide6.QtCore import QObject, QTimer, Signal, Property


class Diagnostics(QObject):
    rosItemsChanged = Signal()
    canBusChanged   = Signal()
    wifiChanged     = Signal()
    wifiIpChanged   = Signal()

    def __init__(self, parent=None):
        super().__init__(parent)
        self._ros_status: dict[str, dict] = {}
        self._ros_items:  list[dict]      = []
        self._last_ros_time: float        = 0.0

        self._can_bus = False
        self._wifi    = False
        self._wifi_ip = ''
        self._sys_lock = threading.Lock()

        self._poll_timer = QTimer(self)
        self._poll_timer.setInterval(5000)
        self._poll_timer.timeout.connect(self._on_poll_timer)
        self._poll_timer.start()
        QTimer.singleShot(100, self._on_poll_timer)

    # ------------------------------------------------------------------ #
    # Properties                                                           #
    # ------------------------------------------------------------------ #

    @Property('QVariantList', notify=rosItemsChanged)
    def rosItems(self) -> list:
        return self._ros_items

    @Property(bool, notify=canBusChanged)
    def canBus(self) -> bool:
        return self._can_bus

    @Property(bool, notify=wifiChanged)
    def wifi(self) -> bool:
        return self._wifi

    @Property(str, notify=wifiIpChanged)
    def wifiIp(self) -> str:
        return self._wifi_ip

    # ------------------------------------------------------------------ #
    # ROS callback (called from ROS executor thread)                       #
    # ------------------------------------------------------------------ #

    def update_from_diagnostics(self, msg) -> None:
        self._last_ros_time = time.monotonic()
        for status in msg.status:
            level = status.level
            # level is int8 in rclpy; guard against bytes representation too
            if isinstance(level, (bytes, bytearray)):
                level = level[0]
            self._ros_status[status.name] = {
                'ok':      level == 0,
                'warning': level == 1,
                'message': status.message,
            }
        self._emit_ros_items()

    # ------------------------------------------------------------------ #
    # Internal helpers                                                     #
    # ------------------------------------------------------------------ #

    def _emit_ros_items(self) -> None:
        self._ros_items = [
            {'name': k, 'ok': v['ok'], 'warning': v['warning'], 'message': v['message']}
            for k, v in sorted(self._ros_status.items())
        ]
        self.rosItemsChanged.emit()

    def _on_poll_timer(self) -> None:
        if self._last_ros_time > 0.0:
            if time.monotonic() - self._last_ros_time > 5.0:
                self._ros_status.clear()
                self._emit_ros_items()
        threading.Thread(target=self._check_systems, daemon=True).start()

    def _check_systems(self) -> None:
        can_ok        = _probe_can()
        wifi_ok, ip   = _probe_wifi_info()
        with self._sys_lock:
            changes = []
            if self._can_bus != can_ok:
                self._can_bus = can_ok
                changes.append(self.canBusChanged)
            if self._wifi != wifi_ok:
                self._wifi = wifi_ok
                changes.append(self.wifiChanged)
            if self._wifi_ip != ip:
                self._wifi_ip = ip
                changes.append(self.wifiIpChanged)
        for sig in changes:
            sig.emit()


# ------------------------------------------------------------------ #
# System probes (module-level, no Qt dependencies)                    #
# ------------------------------------------------------------------ #

def _probe_can() -> bool:
    """True if at least one CAN interface is UP and ERROR-ACTIVE."""
    try:
        r = subprocess.run(
            ['ip', '-details', 'link', 'show', 'type', 'can'],
            capture_output=True, text=True, timeout=2,
        )
        return 'UP' in r.stdout and 'ERROR-ACTIVE' in r.stdout
    except Exception:
        return False


def _probe_wifi_info() -> tuple[bool, str]:
    """Returns (is_up, ip_address). Uses pure sysfs for detection, ip for IP."""
    net_root = '/sys/class/net'
    try:
        for iface in os.listdir(net_root):
            if not os.path.isdir(f'{net_root}/{iface}/wireless'):
                continue
            try:
                with open(f'{net_root}/{iface}/operstate') as f:
                    if f.read().strip() == 'up':
                        return True, _get_iface_ip(iface)
            except OSError:
                continue
    except OSError:
        pass
    return False, ''


def _get_iface_ip(iface: str) -> str:
    try:
        r = subprocess.run(
            ['ip', '-4', 'addr', 'show', iface],
            capture_output=True, text=True, timeout=2,
        )
        m = re.search(r'inet (\d+\.\d+\.\d+\.\d+)', r.stdout)
        return m.group(1) if m else ''
    except Exception:
        return ''

"""Single ROS 2 node that drives all GUI Qt objects."""

import math
import threading

import rclpy
from rclpy.node import Node
from rclpy.executors import SingleThreadedExecutor
from tf2_ros import Buffer, TransformListener
from builtin_interfaces.msg import Duration
from std_msgs.msg import Bool

try:
    from sensor_msgs.msg import Image as RosImage
    _HAS_IMAGE = True
except ImportError:
    _HAS_IMAGE = False


class KrabiGuiNode(Node):
    def __init__(self, robot_status, match, camera_state):
        super().__init__('krabi_gui_node')
        self._robot_status  = robot_status
        self._match         = match
        self._camera_state  = camera_state

        self._tf_buffer   = Buffer()
        self._tf_listener = TransformListener(self._tf_buffer, self)
        self.create_timer(0.05, self._on_tf_timer)  # 20 Hz

        self.create_subscription(Duration, '/krabi_ns/remaining_time',
                                 self._on_time, 10)
        if _HAS_IMAGE:
            self.create_subscription(RosImage, '/krabi_ns/krabi_cam_raw',
                                     self._on_image, 10)

        self._team_pub  = self.create_publisher(Bool, '/krabi_ns/is_blue',    1)
        self._start_pub = self.create_publisher(Bool, '/krabi_ns/match_start', 1)

    # ------------------------------------------------------------------
    # ROS callbacks (background thread)
    # ------------------------------------------------------------------

    def _on_tf_timer(self) -> None:
        try:
            tf = self._tf_buffer.lookup_transform(
                'map', 'base_link', rclpy.time.Time())
            t = tf.transform.translation
            r = tf.transform.rotation
            yaw = math.atan2(2.0 * (r.w * r.z + r.x * r.y),
                             1.0 - 2.0 * (r.y * r.y + r.z * r.z))
            self._robot_status.updatePosition(t.x, t.y, yaw)
        except Exception:
            pass  # TF not yet available — keep last known pose

    def _on_time(self, msg: Duration) -> None:
        self._match.setTimeRemaining(msg.sec)

    def _on_image(self, msg) -> None:
        self._camera_state.update_frame(msg)

    # ------------------------------------------------------------------
    # Publishers (called from Qt main thread via slots)
    # ------------------------------------------------------------------

    def publish_team(self, is_blue: bool) -> None:
        m = Bool(); m.data = is_blue
        self._team_pub.publish(m)

    def publish_start(self) -> None:
        m = Bool(); m.data = True
        self._start_pub.publish(m)


def start_ros(robot_status, match, camera_state) -> KrabiGuiNode:
    rclpy.init()
    node = KrabiGuiNode(robot_status, match, camera_state)
    executor = SingleThreadedExecutor()
    executor.add_node(node)
    threading.Thread(target=executor.spin, daemon=True).start()
    return node

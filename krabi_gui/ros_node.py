"""Single ROS 2 node that drives all GUI Qt objects."""

import math
import threading

import rclpy
from rclpy.node import Node
from rclpy.executors import SingleThreadedExecutor
from tf2_ros import Buffer, TransformListener
import tf2_geometry_msgs  # noqa: F401 — registers PoseStamped transform support
from builtin_interfaces.msg import Duration
from geometry_msgs.msg import PoseStamped
from sensor_msgs.msg import BatteryState
from std_msgs.msg import Bool

try:
    from sensor_msgs.msg import Image as RosImage
    _HAS_IMAGE = True
except ImportError:
    _HAS_IMAGE = False

try:
    from krabi_msgs.msg import Actuators2025
    _HAS_ACTUATORS = True
except ImportError:
    _HAS_ACTUATORS = False

try:
    from diagnostic_msgs.msg import DiagnosticArray
    _HAS_DIAGNOSTICS = True
except ImportError:
    _HAS_DIAGNOSTICS = False

try:
    from rclpy.qos import QoSProfile, ReliabilityPolicy, HistoryPolicy
    _CAM_QOS = QoSProfile(
        depth=1,
        history=HistoryPolicy.KEEP_LAST,
        reliability=ReliabilityPolicy.BEST_EFFORT,
    )
except Exception:
    _CAM_QOS = 1  # fallback: plain integer depth


class KrabiGuiNode(Node):
    def __init__(self, robot_status, match, camera_state, tirette,
                 diagnostics=None, publish_tirette: bool = False,
                 simu: bool = False):
        super().__init__('krabi_gui_node')
        self._robot_status  = robot_status
        self._match         = match
        self._camera_state  = camera_state
        self._tirette       = tirette
        self._diagnostics   = diagnostics

        self._tf_buffer   = Buffer()
        self._tf_listener = None   # created lazily in enable_tf()
        self._tf_active   = False  # gate for _on_tf_timer
        self.create_timer(0.3, self._on_tf_timer)  # 3.3 Hz

        self._obstacle_front_msg:  PoseStamped | None = None
        self._obstacle_behind_msg: PoseStamped | None = None

        self.create_subscription(Duration, '/remaining_time',
                                 self._on_time, 10)

        self._cam_topic = None
        self._cam_sub   = None
        if _HAS_IMAGE:
            self._cam_topic = '/krabi_ns/krabi_cam_simu/image_raw' if simu else '/krabi_ns/krabi_cam/image_raw'
            # camera subscription created lazily via enable_camera()

        if _HAS_ACTUATORS:
            self.create_subscription(Actuators2025, '/krabi_ns/actuators2026',
                                     self._on_actuators, 10)

        self.create_subscription(PoseStamped, '/krabi_ns/obstacle_pose_stamped',
                                 self._on_obstacle_front, 10)
        self.create_subscription(PoseStamped, '/krabi_ns/obstacle_behind_pose_stamped',
                                 self._on_obstacle_behind, 10)
        if simu:
            self._robot_status.updatePowerBattery(11.6, 0.78)
            self._robot_status.updateElecBattery(10.4, 0.43)
        else:
            self.create_subscription(BatteryState, '/krabi_ns/power_battery',
                                    self._on_power_battery, 10)
            self.create_subscription(BatteryState, '/krabi_ns/elec_battery',
                                    self._on_elec_battery, 10)

        self.create_subscription(Bool, '/krabi_ns/tirette', self._on_tirette, 10)

        if _HAS_DIAGNOSTICS and self._diagnostics is not None:
            self.create_subscription(
                DiagnosticArray, '/diagnostics', self._on_diagnostics, 10)

        # Team colour: publish when GUI is the authority, subscribe otherwise
        self._team_pub = None
        if publish_tirette:
            self._team_pub = self.create_publisher(Bool, '/krabi_ns/is_blue', 1)
        else:
            self.create_subscription(Bool, '/krabi_ns/is_blue', self._on_is_blue, 1)

        self._recalage_pub = self.create_publisher(Bool, '/krabi_ns/recalage', 1)
        self._start_pub    = self.create_publisher(Bool, '/krabi_ns/match_start', 1)

    # ------------------------------------------------------------------
    # Page-aware subscription management (called from Qt main thread)
    # ------------------------------------------------------------------

    def enable_camera(self) -> None:
        if self._cam_sub is None and self._cam_topic is not None:
            self._cam_sub = self.create_subscription(
                RosImage, self._cam_topic, self._on_image, _CAM_QOS)

    def disable_camera(self) -> None:
        if self._cam_sub is not None:
            self.destroy_subscription(self._cam_sub)
            self._cam_sub = None

    def enable_tf(self) -> None:
        if not self._tf_active:
            self._tf_active   = True
            self._tf_listener = TransformListener(self._tf_buffer, self)

    def disable_tf(self) -> None:
        self._tf_active = False
        if self._tf_listener is not None:
            self.destroy_subscription(self._tf_listener.tf_sub)
            self.destroy_subscription(self._tf_listener.tf_static_sub)
            self._tf_listener = None

    # ------------------------------------------------------------------
    # ROS callbacks (background thread)
    # ------------------------------------------------------------------

    def _on_tf_timer(self) -> None:
        if not self._tf_active:
            return
        try:
            tf = self._tf_buffer.lookup_transform(
                'map', 'base_link', rclpy.time.Time())
            t = tf.transform.translation
            r = tf.transform.rotation
            yaw = math.atan2(2.0 * (r.w * r.z + r.x * r.y),
                             1.0 - 2.0 * (r.y * r.y + r.z * r.z))
            self._robot_status.updatePosition(t.x, t.y, yaw)

            if self._obstacle_front_msg is not None:
                p = self._tf_buffer.transform(self._obstacle_front_msg, 'map',
                                              timeout=rclpy.duration.Duration(seconds=0.0))
                self._robot_status.updateObstacleFront(
                    p.pose.position.x, p.pose.position.y)

            if self._obstacle_behind_msg is not None:
                p = self._tf_buffer.transform(self._obstacle_behind_msg, 'map',
                                              timeout=rclpy.duration.Duration(seconds=0.0))
                self._robot_status.updateObstacleBehind(
                    p.pose.position.x, p.pose.position.y)

        except Exception:
            pass  # TF not yet available — keep last known pose

    def _on_time(self, msg: Duration) -> None:
        self._match.setTimeRemaining(msg.sec)

    def _on_image(self, msg) -> None:
        self._camera_state.update_frame(msg)

    def _on_actuators(self, msg) -> None:
        self._match.setScore(msg.score)

    def _on_obstacle_front(self, msg: PoseStamped) -> None:
        self._obstacle_front_msg = msg

    def _on_obstacle_behind(self, msg: PoseStamped) -> None:
        self._obstacle_behind_msg = msg

    def _on_power_battery(self, msg: BatteryState) -> None:
        self._robot_status.updatePowerBattery(msg.voltage, msg.percentage)

    def _on_elec_battery(self, msg: BatteryState) -> None:
        self._robot_status.updateElecBattery(msg.voltage, msg.percentage)

    def _on_tirette(self, msg: Bool) -> None:
        self._tirette.updateInserted(msg.data)

    def _on_diagnostics(self, msg) -> None:
        self._diagnostics.update_from_diagnostics(msg)

    def _on_is_blue(self, msg: Bool) -> None:
        self._match.setTeamColor('blue' if msg.data else 'yellow')

    # ------------------------------------------------------------------
    # Publishers (called from Qt main thread via slots)
    # ------------------------------------------------------------------

    def publish_team(self, is_blue: bool) -> None:
        if self._team_pub is not None:
            m = Bool(); m.data = is_blue
            self._team_pub.publish(m)

    def publish_recalage(self) -> None:
        m = Bool(); m.data = True
        self._recalage_pub.publish(m)

    def publish_start(self) -> None:
        m = Bool(); m.data = True
        self._start_pub.publish(m)


def start_ros(robot_status, match, camera_state, tirette,
              diagnostics=None, publish_tirette: bool = False,
              simu: bool = False) -> KrabiGuiNode:
    rclpy.init()
    node = KrabiGuiNode(robot_status, match, camera_state, tirette,
                        diagnostics=diagnostics,
                        publish_tirette=publish_tirette, simu=simu)
    try:
        from rclpy.executors import StaticSingleThreadedExecutor
        executor = StaticSingleThreadedExecutor()
    except ImportError:
        executor = SingleThreadedExecutor()
    executor.add_node(node)
    threading.Thread(target=executor.spin, daemon=True).start()
    return node

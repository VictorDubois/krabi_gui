
import rclpy
from rclpy.node import Node
from krabi_msgs.msg import OdomLighter
from std_msgs.msg import Bool
from nav_msgs.msg import Odometry
from geometry_msgs.msg import Twist

class RosInterface(Node):
    def __init__(self):
        super().__init__('krabi_gui_ros_interface')
        
        #rclpy.init(args=args)
        
        # Publisher for robot velocity commands
        self.cmd_vel_pub = self.create_publisher(Twist, '/cmd_vel', 10)
        
        # Subscriber for robot odometry
        self.odom_sub = self.create_subscription(Odometry, '/odom', self.odom_callback, 10)
        
        # Subscriber for match state
        self.match_state_sub = self.create_subscription(Bool, '/match_state', self.match_state_callback, 10)
        
        # Internal state
        self.robot_status = None
        self.match_active = False

    def odom_callback(self, msg):
        # Update robot status based on odometry message
        if not self.robot_status:
            from .robot_status import RobotStatus
            self.robot_status = RobotStatus()
        
        self.robot_status.x = msg.pose.pose.position.x
        self.robot_status.y = msg.pose.pose.position.y
        # Assuming orientation is in quaternion form, convert to angle (simplified)
        import math
        qz = msg.pose.pose.orientation.z
        qw = msg.pose.pose.orientation.w
        self.robot_status.angle = math.atan2(2.0 * (qw * qz), 1.0 - 2.0 * (qz * qz))

    def match_state_callback(self, msg):
        # Update match state based on incoming message
        self.match_active = msg.data
IHM for the robot Krabi

<img width="822" height="540" alt="image" src="https://github.com/user-attachments/assets/f37fbbde-5660-4250-abe4-3935b2da68c0" />

<img width="822" height="540" alt="image" src="https://github.com/user-attachments/assets/64aea056-fdfd-4193-a245-e2be47b85c77" />

<img width="822" height="540" alt="image" src="https://github.com/user-attachments/assets/514d1fa2-3169-4dd5-992f-2d5c7807aa1e" />

<img width="822" height="540" alt="image" src="https://github.com/user-attachments/assets/9dee1577-5ff5-4427-a459-c2fc4067ba48" />

(we can see here that the RoIs are tuned for the real robot, and not for the simulation!)

Compatible with ROS messages from anywhere, so can be tested from simulation, or from a .mcap record: `ros2 bag play path_to_file.mcap`

To start: source the venv + ROS environment, go to the krabi_gui folder, and run python3 ./krabi_gui.py

On the real robot, there is a service dedicated: krabi_gui.service
@TODO: commit and push startKrabuiGui.sh

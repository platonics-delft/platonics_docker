# Platonics docker

Make sure you have docker installed.
Installation for docker for [linux ubuntu](https://docs.docker.com/desktop/setup/install/linux/ubuntu/)

## Build the image
```bash
./build_docker
```

## Download the image

A running container is available on dockerhub. To download the image, run the following command:
```bash
docker pull maxspahn/platonics_ros
```

## Run the container

In order for this container to be useful, it is expected that the controller is
running on the real-time computer and that the real-time computer is connected
stable to the same network as the computer running this docker. We do not
recommend running the controller and the container on the same machine, although
it might work.

The controller and its installation instructions can be found
[here](https://github.com/franzesegiovanni/franka_human_friendly_controllers).

First, run the controller on the real-time computer. Then, run the following
```bash
xhost +local:docker
./run_docker <ip-of-real-time-computer> <ip-of-computer-running-docker>
```

Then you can open `localhost:8080` in your browser to interact with the robot,
record trajectories and execute them.

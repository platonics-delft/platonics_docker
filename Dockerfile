# Select base image
FROM ros:noetic-ros-base

# Set environment variables that persist in the container
ENV DEBIAN_FRONTEND=noninteractive
ENV ROS_DISTRO=noetic
ENV ROS_ROOT=/opt/ros/$ROS_DISTRO
ENV ROSDEP_SOURCES=/etc/ros/rosdep/sources.list.d
ENV TZ=Europe/Amsterdam
ENV ROOT=/root
ENV WS=$ROOT/catkin_ws

ENV DISPLAY=:0

COPY .tmux.conf $ROOT/.tmux.conf

# Set the timezone
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Create the ROOT directory

RUN mkdir -p $ROOT




# Install ubuntu packages
RUN apt-get update \
    && apt install -y --no-install-recommends \
        build-essential \
        git \
        python3-catkin-tools \
        python3-pip \
        tmux \
        curl \
        lsb-release \
        gnupg2 \
        tmuxp \
        npm \
    && apt clean \
    && rm -rf /var/lib/apt/lists/*

RUN apt-get update && apt install -y --no-install-recommends \
        ros-noetic-cv-bridge \
        ros-noetic-tf2-ros \
        ros-noetic-tf \
    && apt clean \
    && rm -rf /var/lib/apt/lists/*

RUN apt-get update && apt install -y --no-install-recommends \
        libeigen3-dev \
        ros-noetic-rqt-reconfigure \
        ros-noetic-diagnostic-updater \
        ros-noetic-tf2 \
        ros-noetic-vision-opencv \
        ros-noetic-image-common \
        ros-noetic-actionlib-tools \
        ros-noetic-dynamic-reconfigure \
        ros-noetic-ddynamic-reconfigure \
        ros-noetic-rosbridge-suite \
        ros-noetic-franka-gripper \
        ros-noetic-franka-msgs \
    && apt clean \
    && rm -rf /var/lib/apt/lists/*

RUN sudo mkdir -p /etc/apt/keyrings

RUN curl -sSf https://librealsense.intel.com/Debian/librealsense.pgp | tee /etc/apt/keyrings/librealsense.pgp > /dev/null


RUN echo "deb [signed-by=/etc/apt/keyrings/librealsense.pgp] https://librealsense.intel.com/Debian/apt-repo `lsb_release -cs` main" | sudo tee /etc/apt/sources.list.d/librealsense.list





# Install librealsense2
RUN apt-get update && apt-get install -y librealsense2-dev


# Install curl to download Node.js setup script
RUN apt-get update && \
    apt-get install -y curl && \
    curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs \
    && apt clean \
    && rm -rf /var/lib/apt/lists/*

# Ensure you have the correct Node.js version
RUN node -v

# Upgrade npm to version 10.8.2
RUN npm install -g npm@10.8.2 && npm -v && npm cache clean --force


RUN apt-get update && apt-get install -y \
  libx11-xcb1 \
  libxcb1 \
  && apt clean \
  && rm -rf /var/lib/apt/lists/*


# Create catkin workspace
RUN mkdir -p $WS/src \
  && cd $WS \
  && catkin init \
  && catkin config --extend /opt/ros/$ROS_DISTRO \
  && catkin build

# Clone required packages
RUN cd $WS/src \
  && git clone https://github.com/platonics-delft/panda-ros-py.git \
  && git clone https://github.com/platonics-delft/platonics_robot_teaching.git \
  && git clone https://github.com/platonics-delft/platonics_vision.git \
  && git clone https://github.com/platonics-delft/platonics_gui.git \
  && git clone --branch ros1-legacy https://github.com/IntelRealSense/realsense-ros.git \
  && git clone https://github.com/platonics-delft/platonics_dataset.git \
  && git clone https://github.com/platonics-delft/platonics_tools.git

RUN echo "Last updated at $(date)" > last_update.txt


## Pull latest changes in repos
RUN cd $WS/src/panda-ros-py \
  && git checkout ft-remove-franka-copies \
  && cd $WS/src/platonics_robot_teaching \
  && git pull \
  && cd $WS/src/platonics_vision \
  && git pull \
  && cd $WS/src/platonics_gui \
  && git pull \
  && cd $WS/src/platonics_dataset \
  && git pull \
  && cd $WS/src/platonics_tools \
  && git pull




# Build the workspace
RUN set -x \
  && cd $WS \
  && catkin build

# Install npm packages

RUN cd $WS/src/platonics_gui \
  && npm install \
  && npm cache clean --force

# Install python dependencies
RUN pip3 install --no-cache-dir -r $WS/src/platonics_robot_teaching/requirements.txt \
  && pip3 install --no-cache-dir -r $WS/src/platonics_dataset/requirements.txt \
  && pip3 install --no-cache-dir -r $WS/src/panda-ros-py/requirements.txt

# Copy tmuxp config file

COPY start_app.yaml $ROOT/start_app.yaml


# Set the entrypoint
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]











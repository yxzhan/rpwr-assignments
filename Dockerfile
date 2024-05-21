FROM intel4coro/base-notebook:20.04-noetic-vnc

ENV PATH=$PATH:/home/user/${NB_USER}/bin
ENV TURTLEBOT3_MODEL=waffle_pi

USER root
RUN apt-get update && \
    apt-get install -y \
    ros-noetic-turtlebot3-msgs \
    ros-noetic-turtlebot3-description \
    ros-noetic-turtlebot3-teleop \
    ros-noetic-turtlebot3-navigation \
    ros-noetic-dwa-local-planner \
    byobu \
    iputils-ping && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get clean

RUN sh -c 'echo "deb http://packages.osrfoundation.org/gazebo/ubuntu-stable `lsb_release -cs` main" > /etc/apt/sources.list.d/gazebo-stable.list'
RUN wget http://packages.osrfoundation.org/gazebo.key -O - | apt-key add -
RUN apt-get update
RUN apt-get install -y \
    ignition-citadel \
    ros-noetic-ros-ign

USER ${NB_USER}
WORKDIR ${ROS_WS}/src/
RUN git clone https://github.com/artnie/turtlebot3_simulations -b rpwr && \
    git clone https://github.com/code-iai/iai_office_sim

USER root
RUN rosdep update && rosdep install --from-paths . --ignore-src -r -y

USER ${NB_USER}
WORKDIR  ${ROS_WS}
RUN catkin build

COPY --chown=${NB_USER}:users . /home/${NB_USER}/rpwr-assignments/
WORKDIR /home/${NB_USER}/rpwr-assignments
RUN ln -s $ROS_WS $PWD/ROS_WS

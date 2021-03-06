FROM julia:latest

# Docker GPU support using Nvidia Container Toolkit
# https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html
#
# $ docker run --rm -it --gpus all -v /tmp/.X11-unix:/tmp/.X11-unix -e DISPLAY=$DISPLAY -e QT_X11_NO_MITSHM=1 <image> bash

RUN groupadd -g 999 appuser && \
    useradd -r -u 999 -g appuser appuser

RUN chown -R appuser:appuser /home

RUN apt update
RUN apt-get -y install wget
RUN apt-get -y install libglvnd-dev libgl1-mesa-dev libegl1-mesa-dev libxext6 libx11-6
RUN apt-get -y install git g++ cmake qt5-default python-docutils

# use the -b flag to get a specific branch from gtit clone

WORKDIR /usr/local
RUN git clone https://github.com/c42f/displaz.git
WORKDIR /usr/local/displaz/build_external
RUN cmake ../thirdparty/external && make -j4

WORKDIR /usr/local/displaz/build
RUN cmake .. && make -j4 install

ENV PATH "/usr/local/bin/:${PATH}"

WORKDIR /playpen

# Env vars for the nvidia-container-runtime.
ENV NVIDIA_VISIBLE_DEVICES all
ENV NVIDIA_DRIVER_CAPABILITIES graphics,utility,compute

USER appuser
CMD /bin/bash

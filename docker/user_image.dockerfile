FROM nvidia/cuda:10.2-devel-ubuntu18.04

RUN apt update && apt install sudo -y

# http://fabiorehm.com/blog/2014/09/11/running-gui-apps-with-docker/
# NOTE! If your uid is not 1000, update uid and gid below. echo ${UID} to check
RUN export uid=1000 gid=1000 && \
    sudo mkdir -p /home/developer && \
    echo "developer:x:${uid}:${gid}:Developer,,,:/home/developer:/bin/bash" >> /etc/passwd && \
    echo "developer:x:${uid}:" >> /etc/group && \
    echo "developer ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/developer && \
    chmod 0440 /etc/sudoers.d/developer && \
    chown ${uid}:${gid} -R /home/developer

# https://serverfault.com/questions/949991/how-to-install-tzdata-on-a-ubuntu-docker-image
RUN export DEBIAN_FRONTEND=noninteractive && \
    apt install -y tzdata && \
    ln -fs /usr/share/zoneinfo/America/Los_Angeles /etc/localtime && \
    dpkg-reconfigure --frontend noninteractive tzdata

USER developer

RUN sudo apt -y install \
  bison \
  clang-tools \
  cmake \
  doxygen \
  flex \
  libceres-dev \
  libeigen3-dev \
  libfaac-dev \
  libfaad-dev \
  libglew-dev \
  libglfw3-dev \
  libglm-dev \
  libmp3lame-dev \
  libopencv-dev \
  libopenexr-dev \
  libpng-dev \
  libportaudio-ocaml-dev \
  librtmp-dev \
  libturbojpeg0-dev \
  libx264-dev \
  ninja-build \
  ocl-icd-opencl-dev \
  opencl-headers \
  portaudio19-dev \
  qt5-default \
  qtmultimedia5-dev \
  qttools5-dev \
  swig \
  xxd \
  wget \
  vim

RUN sudo apt -y install gcc-6 g++-6 && \
    sudo update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-6 20 && \
    sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-6 20

RUN cd /home/developer && sudo apt install git -y && git clone https://github.com/stitchEm/stitchEm.git .

RUN sudo apt install vim -y

RUN sudo apt install libssl-dev -y

RUN cd /home/developer && wget https://github.com/Kitware/CMake/releases/download/v3.17.2/cmake-3.17.2.tar.gz && \
    tar -xvf cmake-3.17.2.tar.gz && cd cmake-3.17.2 && ./bootstrap && make && sudo make install

RUN sudo apt install nvidia-opencl-dev libnvidia-decode-440 -y

RUN cd /home/developer && cmake -DGPU_BACKEND_CUDA=ON -DGPU_BACKEND_OPENCL=OFF -G Ninja  . && \
    ninja

# docker build --tag stitchem/stitchem-cuda-user:latest --file user_image.dockerfile .
# docker run --gpus all -i -t -e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix  stitchem/stitchem-cuda-user:latest bash

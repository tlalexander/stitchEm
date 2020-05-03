#FROM stitchem/stitchem-cudax:latest
FROM nvidia/cudagl:10.2-devel

RUN apt update && apt install sudo

# Replace 1000 with your user / group id
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
  wget \
  xxd

RUN sudo apt -y install gcc-6 g++-6 && \
    sudo update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-6 20 && \
    sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-6 20

RUN sudo apt -y install git cmake


RUN cd /home/developer && git clone https://github.com/stitchEm/stitchEm.git .

RUN sudo apt install libssl-dev -y

RUN cd /home/developer && wget https://github.com/Kitware/CMake/releases/download/v3.17.2/cmake-3.17.2.tar.gz && \
    tar -xvf cmake-3.17.2.tar.gz && cd cmake-3.17.2 && ./bootstrap && make && sudo make install

 #&& \
  #  cmake -DGPU_BACKEND_CUDA=ON -DGPU_BACKEND_OPENCL=ON -G Ninja  stitchEm && \
  #  ninja

RUN sudo apt install clang

# RUN cd /home/developer && cmake -DGPU_BACKEND_CUDA=ON -DGPU_BACKEND_OPENCL=ON -G Ninja  . && \
 #  ninja

RUN cd /home/developer && cmake -DGPU_BACKEND_CUDA=OFF -DGPU_BACKEND_OPENCL=ON -G Ninja . && \
ninja

# docker build --tag stitchem/stitchem-cuda-user:latest --file user_image.dockerfile .
# docker run --gpus all -i -t -e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix  stitchem/stitchem-cuda-user:latest bash

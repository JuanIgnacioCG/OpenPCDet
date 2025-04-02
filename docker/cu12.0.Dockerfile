FROM nvidia/cuda:12.0.0-devel-ubuntu22.04

# Environment setup
ENV NVENCODE_CFLAGS="-I/usr/local/cuda/include"
ENV CV_VERSION=4.x
ENV DEBIAN_FRONTEND=noninteractive
ENV TORCH_CUDA_ARCH_LIST="6.0;6.1;7.0;7.5;8.0;8.6;8.9+PTX"

# Install system dependencies and GUI/X11 support
RUN apt-get update && apt-get install -y \
    git zip unzip wget vim nano ffmpeg libsm6 libxext6 libxrender1 \
    libglib2.0-0 libgl1-mesa-glx libgtk2.0-dev libcanberra-gtk-module \
    build-essential python3 python3-pip cmake \
    libglfw3-dev libglew-dev x11-xserver-utils x11-utils \
    x11-apps \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Upgrade pip first
RUN pip3 install --upgrade pip
RUN pip3 install ipython

#  Install PyTorch before others (CUDA 12.1 compatible)
RUN pip3 install torch==2.1.0 torchvision==0.16.0 torchaudio==2.1.0 --index-url https://download.pytorch.org/whl/cu121

# Copy local OpenPCDet repo into the image
COPY OpenPCDet /OpenPCDet
WORKDIR /OpenPCDet

# Install OpenPCDet requirements
RUN pip3 install -r requirements.txt

#  Now install other dependencies
RUN pip3 install \
    numpy\<2.0 \
    kornia==0.5.8 \
    spconv-cu120 \
    opencv-python-headless \
    matplotlib \
    open3d \
    wandb \
    protobuf==3.20.*

# Install OpenPCDet in dev mode
RUN python3 setup.py develop

# Set working directory for interactive use
WORKDIR /OpenPCDet/tools

FROM  docker.repository.cloudera.com/cdsw/engine:13

ARG OS_RELEASE="ubuntu1804"

RUN rm -f /etc/apt/sources.list.d/cloudera.list && \
    rm -f /etc/apt/sources.list.d/yarn.list && \
    apt-get update && apt-get install -y --no-install-recommends \
    gnupg2 curl ca-certificates && \
    curl -fsSL https://developer.download.nvidia.com/compute/cuda/repos/${OS_RELEASE}/x86_64/7fa2af80.pub | apt-key add - && \
    echo "deb https://developer.download.nvidia.com/compute/cuda/repos/${OS_RELEASE}/x86_64 /" > /etc/apt/sources.list.d/cuda.list && \
    echo "deb https://developer.download.nvidia.com/compute/machine-learning/repos/${OS_RELEASE}/x86_64 /" > /etc/apt/sources.list.d/nvidia-ml.list && \
    apt-get purge --autoremove -y curl && \
    rm -rf /var/lib/apt/lists/*


ENV CUDA_VERSION 11.1.1
LABEL com.nvidia.cuda.version="${CUDA_VERSION}"

ENV CUDA_PKG_VERSION 11.1=11.1.74-1

RUN rm -f /etc/apt/sources.list.d/cloudera.list && \
    rm -f /etc/apt/sources.list.d/yarn.list && \
    apt-get update &&  \
    apt-get install -y --no-install-recommends cuda-cudart-11-1=11.1.74-1 \
    cuda-compat-11.1 && \
    ln -s cuda-11.1 /usr/local/cuda && \
    rm -rf /var/lib/apt/lists/*

RUN echo "/usr/local/cuda/lib64" >> /etc/ld.so.conf.d/cuda.conf && \
    ldconfig

# RUN echo "/usr/local/nvidia/lib" >> /etc/ld.so.conf.d/nvidia.conf && \
#     echo "/usr/local/nvidia/lib64" >> /etc/ld.so.conf.d/nvidia.conf
# ENV PATH /usr/local/nvidia/bin:/usr/local/cuda/bin:${PATH}
# ENV LD_LIBRARY_PATH /usr/local/nvidia/lib:/usr/local/nvidia/lib64

ENV NVIDIA_VISIBLE_DEVICES all
ENV NVIDIA_DRIVER_CAPABILITIES compute,utility
ENV NVIDIA_REQUIRE_CUDA "cuda>=11.1 brand=tesla,driver>=418,driver<419 brand=tesla,driver>=440,driver<441 driver>=450,driver<451"

# Install NCCL (devel)
ENV NCCL_VERSION 2.8.3

RUN apt-get update && apt-get install -y --no-install-recommends \
    cuda-cudart-dev-11-1=11.1.74-1 \
    cuda-command-line-tools-11-1=11.1.1-1 \
    cuda-minimal-build-11-1=11.1.1-1 \
    cuda-libraries-dev-11-1=11.1.1-1 \
    cuda-nvml-dev-11-1=11.1.74-1 \
    libnpp-dev-11-1=11.1.2.301-1 \
    libnccl-dev=2.8.3-1+cuda11.1 \
    libcublas-dev-11-1=11.3.0.106-1 \
    libcusparse-11-1=11.3.0.10-1 \
    libcusparse-dev-11-1=11.3.0.10-1 \
    libnpp-11-1=11.1.2.301-1 \
    cuda-nvtx-11-1=11.1.74-1 \
    libcublas-11-1=11.3.0.106-1 \
    libnccl2=$NCCL_VERSION-1+cuda11.1 \
    && rm -rf /var/lib/apt/lists/*

# apt from auto upgrading the cublas package. See https://gitlab.com/nvidia/container-images/cuda/-/issues/88
RUN apt-mark hold libcublas-dev-11.1 libnccl-dev libcublas-11-1 libnccl2
ENV LIBRARY_PATH /usr/local/cuda/lib64/stubs

ENV CUDNN_VERSION 8.0.5.39
LABEL com.nvidia.cudnn.version="${CUDNN_VERSION}"

RUN apt-get update && apt-get install -y --no-install-recommends \
            libcudnn8=$CUDNN_VERSION-1+cuda11.1 \
            libcudnn8-dev=$CUDNN_VERSION-1+cuda11.1 && \
    apt-mark hold libcudnn8 && \
    rm -rf /var/lib/apt/lists/*

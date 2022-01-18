ARG PYTHON_VERSION
ARG CUDA_VERSION
ARG NCCL_VERSION
ARG ACUDNN_VERSION

FROM ubuntu

# https://askubuntu.com/questions/831386/gpgkeys-key-f60f4b3d7fa2af80-not-found-on-keyserver/831535#831535
RUN apt-get update && \
    apt-get install -y --no-install-recommends ca-certificates apt-transport-https gnupg2 wget && \
    wget -qO - https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/7fa2af80.pub | apt-key add - && \
    echo "deb https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1604/x86_64 /" > /etc/apt/sources.list.d/cuda.list && \
    echo "deb https://developer.download.nvidia.com/compute/machine-learning/repos/ubuntu1604/x86_64 /" > /etc/apt/sources.list.d/nvidia-ml.list && \
    rm -rf /var/lib/apt/lists/* # buildkit 15.9MB buildkit.dockerfile.v0

ARG CUDA_VERSION
ENV CUDA_VERSION=${CUDA_VERSION}

RUN apt-get update && apt-get install wget && \
    apt-get install -y --no-install-recommends cuda-cudart-11-1=11.1.74-1 cuda-compat-11-1 && \
    ln -s cuda-11.1 /usr/local/cuda && rm -rf /var/lib/apt/lists/* # buildkit 32.6MB buildkit.dockerfile.v0

RUN echo "/usr/local/nvidia/lib" >> /etc/ld.so.conf.d/nvidia.conf && \
    echo "/usr/local/nvidia/lib64" >> /etc/ld.so.conf.d/nvidia.conf # buildkit 46B buildkit.dockerfile.v0 

ENV PATH=/usr/local/nvidia/bin:/usr/local/cuda/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin 
ENV LD_LIBRARY_PATH=/usr/local/nvidia/lib:/usr/local/nvidia/lib64
ENV NVIDIA_VISIBLE_DEVICES=all  
ENV NVIDIA_DRIVER_CAPABILITIES=compute,utility  
ENV NVIDIA_REQUIRE_CUDA=cuda>=11.1 brand=tesla,driver>=418,driver<419 brand=tesla,driver>=440,driver<441 brand=tesla,driver>=450,driver<451

ARG NCCL_VERSION
ENV NCCL_VERSION=${NCCL_VERSION}

RUN apt-get update && apt-get install -y --no-install-recommends cuda-libraries-11-1=11.1.1-1 libnpp-11-1=11.1.2.301-1 \
                                      cuda-nvtx-11-1=11.1.74-1 libcublas-11-1=11.3.0.106-1 libnccl2=$NCCL_VERSION-1+cuda11.1 && \
    apt-mark hold libnccl2 && rm -rf /var/lib/apt/lists/* # buildkit 2.39GB buildkit.dockerfile.v0

ENV NCCL_VERSION=2.7.8  
RUN apt-get update && apt-get install -y --no-install-recommends cuda-nvml-dev-11-1=11.1.74-1 cuda-command-line-tools-11-1=11.1.1-1 \
                                      cuda-nvprof-11-1=11.1.105-1 libnpp-dev-11-1=11.1.2.301-1 cuda-libraries-dev-11-1=11.1.1-1 \
                                      cuda-minimal-build-11-1=11.1.1-1 libnccl-dev=2.7.8-1+cuda11.1 libcublas-dev-11-1=11.3.0.106-1 \
                                      libcusparse-11-1=11.3.0.10-1 libcusparse-dev-11-1=11.3.0.10-1 && \
    apt-mark hold libnccl-dev && rm -rf /var/lib/apt/lists/* # buildkit 2.22GB buildkit.dockerfile.v0

ENV LIBRARY_PATH=/usr/local/cuda/lib64/stubs  
ARG CUDNN_VERSION
ENV CUDNN_VERSION=${CUDNN_VERSION}
LABEL com.nvidia.cudnn.version=${CUDNN_VERSION}

RUN apt-get update && apt-get install -y --no-install-recommends libcudnn8=$CUDNN_VERSION-1+cuda11.1 libcudnn8-dev=$CUDNN_VERSION-1+cuda11.1 && \
    apt-mark hold libcudnn8 && rm -rf /var/lib/apt/lists/* # buildkit 4.57GB buildkit.dockerfile.v0

ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1
ENV LD_LIBRARY_PATH=/usr/local/nvidia/lib:/usr/local/nvidia/lib64:/usr/lib/x86_64-linux-gnu:/usr/local/nvidia/lib64:/usr/local/nvidia/bin
ENV PATH=/root/.pyenv/shims:/root/.pyenv/bin:/usr/local/nvidia/bin:/usr/local/cuda/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin  

RUN apt-get update -qq && \
    apt-get install -qqy --no-install-recommends make build-essential libssl-dev zlib1g-dev \
                    libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm libncurses5-dev \
                    libncursesw5-dev xz-utils tk-dev libffi-dev liblzma-dev python-openssl git ca-certificates && \
    rm -rf /var/lib/apt/lists/* # buildkit 164MB buildkit.dockerfile.v0

ARG PYTHON_VERSION
ENV PYTHON_VERISON=${PYTHON_VERSION}

RUN curl https://pyenv.run | bash && git clone https://github.com/momo-lab/pyenv-install-latest.git "$(pyenv root)"/plugins/pyenv-install-latest && \
    pyenv install-latest "${PYTHON_VERSION}" && \
    pyenv global $(pyenv install-latest --print "${PYTHON_VERSION}") # buildkit 218MB buildkit.dockerfile.v0

CMD ["python3", "--version"]

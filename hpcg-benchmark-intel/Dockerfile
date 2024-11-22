FROM ubuntu:22.04

RUN apt-get update
RUN apt-get install -y --no-install-recommends \
    build-essential \
    libopenmpi-dev \
    openmpi-bin \
    gfortran

RUN apt-get wget cmake ca-certificates

RUN apt-get clean && rm -rf /var/lib/apt/lists/*

WORKDIR /opt/hpcg

RUN wget https://www.hpcg-benchmark.org/downloads/hpcg-3.1.tar.gz && \
    tar -xvzf hpcg-3.1.tar.gz && \
    rm hpcg-3.1.tar.gz && \
    mv hpcg-3.1 /opt/hpcg

WORKDIR /opt/hpcg

RUN mkdir build && cd build && \
    cmake -DCMAKE_C_COMPILER=mpicc -DCMAKE_CXX_COMPILER=mpicxx .. && \
    make

RUN ln -s /opt/hpcg/build/bin/xhpcg /usr/local/bin/xhpcg

WORKDIR /opt/hpcg

CMD ["bash"]


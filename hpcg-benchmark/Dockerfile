FROM ubuntu:22.04

RUN apt-get update
RUN apt-get install -y --no-install-recommends \
    build-essential \
    libopenmpi-dev \
    openmpi-bin \
    gfortran

RUN apt-get install -y wget cmake ca-certificates

RUN apt-get clean && rm -rf /var/lib/apt/lists/*

WORKDIR /
RUN wget https://www.hpcg-benchmark.org/downloads/hpcg-3.1.tar.gz
RUN tar -xvzf hpcg-3.1.tar.gz
RUN mv hpcg-3.1 hpcg
RUN rm hpcg-3.1.tar.gz
WORKDIR /hpcg

COPY Make.ubuntu setup/

RUN make arch=ubuntu

WORKDIR /hpcg/bin
COPY HPCG.dat.txt hpcg.dat

CMD ["bash"]
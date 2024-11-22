FROM ubuntu:22.04

RUN apt-get update
RUN apt-get install build-essential emacs -y
RUN apt install libopenmpi-dev -y
RUN apt install openssh-server -y
RUN apt-get install libatlas-base-dev gfortran -y

RUN wget http://www.netlib.org/benchmark/hpl/hpl-2.3.tar.gz
RUN tar xf hpl-2.3.tar.gz
RUN mv hpl-2.3 hpl

WORKDIR /hpl
COPY Make.ubuntu /hpl/Make.ubuntu
RUN make arch=ubuntu
WORKDIR "/hpl/bin/ubuntu"

COPY HPL.dat HPL.dat

CMD ["bash"]
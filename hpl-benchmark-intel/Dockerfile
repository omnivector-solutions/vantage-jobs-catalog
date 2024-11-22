FROM ubuntu:22.04

RUN apt-get update
RUN apt-get install -y --no-install-recommends build-essential libatlas-base-dev libmpich-dev gfortran wget 
RUN apt-get install -y ca-certificates

RUN wget https://netlib.org/benchmark/hpl/hpl-2.3.tar.gz && \
    tar -xvzf hpl-2.3.tar.gz && \
    rm hpl-2.3.tar.gz && \
    mv hpl-2.3 /opt/hpl

RUN ln -s /opt/hpl/include /usr/local/include/hpl

WORKDIR /opt/hpl/

COPY Make.Linux .

#RUN make clean arch=Linux
RUN make arch=Linux

WORKDIR /opt/hpl/bin/Linux/

CMD ["bash"]

FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update \
    && apt install -y software-properties-common wget

RUN wget -O - https://dl.openfoam.org/gpg.key > /etc/apt/trusted.gpg.d/openfoam.asc \
    && add-apt-repository http://dl.openfoam.org/ubuntu

RUN apt update
RUN apt install -y openfoam11

RUN bash -c "source /opt/openfoam11/etc/bashrc"

EXPOSE 8080

CMD ["/bin/bash"]
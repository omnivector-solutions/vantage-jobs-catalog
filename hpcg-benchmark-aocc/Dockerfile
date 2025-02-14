FROM spack/ubuntu-jammy:0.23

RUN apt-get update

#setup aocc
RUN spack install aocc +license-agreed
RUN spack cd -i aocc && spack compiler add $PWD
RUN spack load aocc
RUN spack compiler find

#install hpl
RUN spack install hpcg%aocc +openmp ^openmpi fabrics=auto

RUN spack load hpcg %aocc
RUN mkdir /hpcg
WORKDIR /hpcg
COPY HPCG.dat.txt ./HPCG.dat

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD ["bash"]
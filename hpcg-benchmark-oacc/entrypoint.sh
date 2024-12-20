export CORES_PER_CCX=8

export OMP_PROC_BIND=true
export OMP_PLACES=cores
export OMP_NUM_THREADS=2

export NUM_CORES=$(nproc)
export NUM_MPI_RANKS=$(( $NUM_CORES / $OMP_NUM_THREADS ))
export RANKS_PER_CCX=$(( $CORES_PER_CCX / $OMP_NUM_THREADS ))

source /opt/spack/share/spack/setup-env.sh
spack load hpcg %aocc
exec "$@"
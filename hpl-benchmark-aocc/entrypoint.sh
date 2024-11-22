#!/bin/bash
# Reference https://www.amd.com/en/developer/zen-software-studio/applications/spack/hpl-benchmark.html
# OpenMP Settings
export OMP_NUM_THREADS=4   # 4 threads per MPI rank  - this means 2 ranks per CPU L3cache (Zen 2+) or 1 rank per L3 (Zen 1)
export OMP_PROC_BIND=TRUE  # bind threads to specific resources
export OMP_PLACES="cores"   # bind threads to cores

# AMDBlis (BLAS layer) optimizations
export BLIS_JC_NT=1  # (No outer loop parallelization)
export BLIS_IC_NT=$OMP_NUM_THREADS # (# of 2nd level threads – one per core in the shared L3 cache domain):
export BLIS_JR_NT=1 # (No 4th level threads)
export BLIS_IR_NT=1 # (No 5th level threads)

# Total MPI rank computation
export TOTAL_CORES=$(nproc)
export NUM_MPI_RANKS=$(( $TOTAL_CORES / $OMP_NUM_THREADS ))

source /opt/spack/share/spack/setup-env.sh
spack load hpl %aocc
exec "$@"
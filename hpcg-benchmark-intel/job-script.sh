#!/bin/bash
#SBATCH -J HPCG_intel
#SBATCH --ntasks=8
#SBATCH --output=/nfs/mnt/hpcg_intel/R-%x.%j.out
#SBATCH --error=/nfs/mnt/hpcg_intel/R-%x.%j.err
#SBATCH -t 1:00:00

WORK_DIR=/nfs/mnt/hpcg_intel/$SLURM_JOB_NAME-Job-$SLURM_JOB_ID
mkdir -p $WORK_DIR
cd $WORK_DIR

export APPTAINER_IMAGE=/nfs/mnt/hpcg_intel.sif

# download the singularity image if it is not available yet
if [[ ! -f $APPTAINER_IMAGE ]]
then
    echo "Pulling the singularity image"
    apptainer pull $APPTAINER_IMAGE oras://public.ecr.aws/omnivector-solutions/hpcg_intel:latest
else
    echo "Skipping the image fetch process...we already have the singularity image"
fi

mpirun --np 8 apptainer exec --bind ./HPCG.dat:/opt/hpcg/HPCG.dat $APPTAINER_IMAGE /opt/hpcg/build/bin/xhpl

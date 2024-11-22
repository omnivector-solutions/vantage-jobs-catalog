#!/bin/bash
#SBATCH -J HPL_intel
#SBATCH --ntasks=8
#SBATCH --output=/nfs/mnt/hpl_intel/R-%x.%j.out
#SBATCH --error=/nfs/mnt/hpl_intel/R-%x.%j.err
#SBATCH -t 1:00:00

WORK_DIR=/nfs/mnt/hpl_intel/$SLURM_JOB_NAME-Job-$SLURM_JOB_ID
mkdir -p $WORK_DIR
cd $WORK_DIR

export APPTAINER_IMAGE=/nfs/mnt/hpl_intel.sif

# download the singularity image if it is not available yet
if [[ ! -f $APPTAINER_IMAGE ]]
then
    echo "Pulling the singularity image"
    apptainer pull $APPTAINER_IMAGE oras://public.ecr.aws/omnivector-solutions/hpl_intel:latest
else
    echo "Skipping the image fetch process...we already have the singularity image"
fi

mpirun --np 8 apptainer exec --bind ./HPL.dat:/opt/hpl/bin/Linux/HPL.dat $APPTAINER_IMAGE /opt/hpl/bin/Linux/xhpl

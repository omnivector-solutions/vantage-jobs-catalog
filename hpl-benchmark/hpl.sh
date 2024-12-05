#!/bin/bash
#SBATCH -J HPL
#SBATCH --ntasks=2
#SBATCH --output=/nfs/mnt/hpl/R-%x.%j.out
#SBATCH --error=/nfs/mnt/hpl/R-%x.%j.err
#SBATCH -t 00:05:00

WORK_DIR=/nfs/mnt/hpl/$SLURM_JOB_NAME-Job-$SLURM_JOB_ID
mkdir -p $WORK_DIR
cd $WORK_DIR

export APPTAINER_IMAGE=/nfs/mnt/vantage-jobs-catalog-hpl.sif

# download the singularity image if it is not available yet
if [[ ! -f $APPTAINER_IMAGE ]]
then
    echo "Pulling the singularity image"
    apptainer pull $APPTAINER_IMAGE oras://public.ecr.aws/omnivector-solutions/benchmark:hpl-ubuntu22
else
    echo "Skipping the image fetch process...we already have the singularity image"
fi

mpirun -np 2 apptainer exec $APPTAINER_IMAGE sh -c "cd /hpl/bin/ubuntu/ && ./xhpl"
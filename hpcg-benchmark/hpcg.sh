#!/bin/bash
#SBATCH -J HPCG
#SBATCH --ntasks=2
#SBATCH --output=/nfs/mnt/hpcg/%x-Job-%j/R-%x.%j.out
#SBATCH --error=/nfs/mnt/hpcg/%x-Job-%j/R-%x.%j.err
#SBATCH -t 00:05:00

WORK_DIR=/nfs/mnt/hpcg/$SLURM_JOB_NAME-Job-$SLURM_JOB_ID
mkdir -p $WORK_DIR
cd $WORK_DIR

# move the HPCG.dat top the Workdir
mv $SLURM_SUBMIT_DIR/HPCG.dat.txt ./HPCG.dat

export APPTAINER_IMAGE=/nfs/mnt/vantage-jobs-catalog-hpcg.sif

# download the singularity image if it is not available yet
if [[ ! -f $APPTAINER_IMAGE ]]
then
    echo "Pulling the singularity image"
    apptainer pull $APPTAINER_IMAGE oras://public.ecr.aws/omnivector-solutions/benchmark:hpcg-ubuntu22
else
    echo "Skipping the image fetch process...we already have the singularity image"
fi

apptainer exec $APPTAINER_IMAGE /hpcg/bin/xhpcg

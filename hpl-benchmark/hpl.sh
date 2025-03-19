#!/bin/bash
#SBATCH -J HPL
#SBATCH --ntasks=2
#SBATCH --output=/nfs/mnt/hpl/%x-Job-%j/R-%x.%j.out
#SBATCH --error=/nfs/mnt/hpl/%x-Job-%j/R-%x.%j.err
#SBATCH -t 00:05:00

WORK_DIR=/nfs/mnt/hpl/$SLURM_JOB_NAME-Job-$SLURM_JOB_ID
mkdir -p $WORK_DIR
cd $WORK_DIR

# move the HPL.dat to the Workdir
mv $SLURM_SUBMIT_DIR/HPL.dat.txt ./HPL.dat

export APPTAINER_IMAGE=/nfs/mnt/hpl.sif

# download the singularity image if it is not available yet
if [[ ! -f $APPTAINER_IMAGE ]]
then
    echo "Pulling the singularity image"
    apptainer pull $APPTAINER_IMAGE oras://public.ecr.aws/g5s2h5u4/hpl-benchmark:latest
else
    echo "Skipping the image fetch process...we already have the singularity image"
fi

apptainer exec $APPTAINER_IMAGE sh -c "/hpl/bin/ubuntu/xhpl"
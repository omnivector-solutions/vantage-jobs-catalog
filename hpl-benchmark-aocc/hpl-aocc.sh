#!/bin/bash
#SBATCH -J HPL_oacc
#SBATCH --ntasks=2
#SBATCH --output=/nfs/mnt/hpl_aocc/%x-Job-%j/R-%x.%j.out
#SBATCH --error=/nfs/mnt/hpl_aocc/%x-Job-%j/R-%x.%j.err
#SBATCH -t 00:05:00

WORK_DIR=/nfs/mnt/hpl_aocc/$SLURM_JOB_NAME-Job-$SLURM_JOB_ID
mkdir -p $WORK_DIR
cd $WORK_DIR

# move the HPL.dat to the Workdir
mv $SLURM_SUBMIT_DIR/HPL.dat.txt ./HPL.dat

export APPTAINER_IMAGE=/nfs/mnt/hpl_aocc.sif

# download the singularity image if it is not available yet
if [[ ! -f $APPTAINER_IMAGE ]]
then
    echo "Pulling the singularity image"
    apptainer pull $APPTAINER_IMAGE oras://public.ecr.aws/omnivector-solutions/hpl-benchmark-aocc:latest
else
    echo "Skipping the image fetch process...we already have the singularity image"
fi

apptainer exec $APPTAINER_IMAGE bash -c "source /entrypoint.sh && xhpl"



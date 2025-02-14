#!/bin/bash
#SBATCH -J HPCG_oacc
#SBATCH --ntasks=2
#SBATCH --output=/nfs/mnt/jobs/%u/%x-Job-%j/R-%x.%j.out
#SBATCH --error=/nfs/mnt/jobs/%u/%x-Job-%j/R-%x.%j.err
#SBATCH -t 00:05:00
#SBATCH --get-user-env


export APPTAINER_DIR=/nfs/mnt/apptainer

export APPTAINER_CACHEDIR=$APPTAINER_DIR/cache
export APPTAINER_TMPDIR=$APPTAINER_DIR/tmp
export APPTAINER_IMAGES_DIR=$APPTAINER_DIR/images
export APPTAINER_BINDPATH=/nfs
export TMPDIR=$APPTAINER_TMPDIR

export REMOTE_APPTAINER_IMAGE="oras://public.ecr.aws/omnivector-solutions/hpcg-benchmark-oacc:latest"
export LOCAL_APPTAINER_IMAGE=$APPTAINER_IMAGES_DIR/vantage-jobs-catalog-hpcg_oacc.sif
export WORK_DIR=/nfs/mnt/jobs/$USER/$SLURM_JOB_NAME-Job-$SLURM_JOB_ID

mkdir -p $APPTAINER_TMPDIR $APPTAINER_CACHEDIR $APPTAINER_IMAGES_DIR $WORK_DIR

# move the HPCG.dat top the Workdir
cd $WORK_DIR
mv $SLURM_SUBMIT_DIR/HPCG.dat.txt ./HPCG.dat

# download the singularity image if it is not available yet
if [[ ! -f $LOCAL_APPTAINER_IMAGE ]]
then
    echo "Pulling the singularity image"
    apptainer pull $LOCAL_APPTAINER_IMAGE $REMOTE_APPTAINER_IMAGE
else
    echo "Skipping the image fetch process...we already have the singularity image"
fi

apptainer exec $LOCAL_APPTAINER_IMAGE bash -c "source /entrypoint.sh && xhcg"

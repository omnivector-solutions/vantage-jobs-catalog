#!/bin/bash
#SBATCH --ntasks=8
#SBATCH -J motorbike
#SBATCH --output=/nfs/mnt/jobs/%u/%x-Job-%j/R-%x.%j.out
#SBATCH --error=/nfs/mnt/jobs/%u/%x-Job-%j/R-%x.%j.err
#SBATCH -t 8:00:00
#SBATCH --get-user-env

export APPTAINER_DIR=/nfs/mnt/apptainer

export APPTAINER_CACHEDIR=$APPTAINER_DIR/cache
export APPTAINER_TMPDIR=$APPTAINER_DIR/tmp
export APPTAINER_IMAGES_DIR=$APPTAINER_DIR/images
export APPTAINER_BINDPATH="/nfs"
export TMPDIR=$APPTAINER_TMPDIR

export REMOTE_APPTAINER_IMAGE="oras://public.ecr.aws/omnivector-solutions/cfd-openfoam-motorbike:latest"
export LOCAL_APPTAINER_IMAGE=$APPTAINER_IMAGES_DIR/vantage-jobs-catalog-openfoam11.sif
export WORK_DIR=/nfs/mnt/jobs/$USER/$SLURM_JOB_NAME-Job-$SLURM_JOB_ID

mkdir -p $APPTAINER_TMPDIR $APPTAINER_CACHEDIR $APPTAINER_IMAGES_DIR $WORK_DIR

# clone OpenFOAM-11 if it is not available yet
export OPENFOAM_DIR=/nfs/mnt/jobs/$USER/OpenFOAM-11
if [[ ! -d $OPENFOAM_DIR ]]
then
    echo "Cloning OpenFOAM-11"
    git clone https://github.com/OpenFOAM/OpenFOAM-11 $OPENFOAM_DIR
else
    echo "Skipping clone process...we already have the OpenFOAM-11 source code"
fi

# download the singularity image if it is not available yet
if [[ ! -f $LOCAL_APPTAINER_IMAGE ]]
then
    echo "Pulling the singularity image"
    apptainer pull $LOCAL_APPTAINER_IMAGE $REMOTE_APPTAINER_IMAGE
else
    echo "Skipping the image fetch process...we already have the singularity image"
fi

cd $WORK_DIR

# copy motorBike folder
cp -r $OPENFOAM_DIR/tutorials/incompressibleFluid/motorBike/motorBike .

cd motorBike

apptainer exec --bind $PWD:$HOME $LOCAL_APPTAINER_IMAGE ./Allclean

cp $OPENFOAM_DIR/tutorials/resources/geometry/motorBike.obj.gz constant/geometry/

apptainer exec --bind $PWD:$HOME $LOCAL_APPTAINER_IMAGE blockMesh

apptainer exec --bind $PWD:$HOME $LOCAL_APPTAINER_IMAGE decomposePar -copyZero

mpirun --np 8 apptainer exec --bind $PWD:$HOME $LOCAL_APPTAINER_IMAGE snappyHexMesh -overwrite -parallel

find . -type f -iname "*level*" -exec rm {} \;

mpirun --np 8 apptainer exec --bind $PWD:$HOME $LOCAL_APPTAINER_IMAGE renumberMesh -overwrite

mpirun --np 8 apptainer exec --bind $PWD:$HOME $LOCAL_APPTAINER_IMAGE potentialFoam -initialiseUBCs -parallel

#!/bin/bash
#SBATCH --ntasks=8
#SBATCH -J motorbike
#SBATCH --output=/nfs/mnt/motorbike/R-%x.%j.out
#SBATCH --error=/nfs/mnt/motorbike/R-%x.%j.err
#SBATCH -t 8:00:00
#SBATCH --get-user-env

# clone OpenFOAM-11 if it is not available yet
OPENFOAM_DIR=/nfs/mnt/OpenFOAM-11
if [[ ! -d $OPENFOAM_DIR ]]
then
    echo "Cloning OpenFOAM-11"
    git clone https://github.com/OpenFOAM/OpenFOAM-11 $OPENFOAM_DIR
else
    echo "Skipping clone process...we already have the OpenFOAM-11 source code"
fi

# create a working folder inside the shared directory
WORK_DIR=/nfs/mnt/motorbike/$SLURM_JOB_NAME-Job-$SLURM_JOB_ID
mkdir -p $WORK_DIR
cd $WORK_DIR

# path to the openfoam singularity image
export APPTAINER_IMAGE=/nfs/mnt/openfoam11.sif

# download the openfoam v11 singularity image if it is not available yet
if [[ ! -f $APPTAINER_IMAGE ]]
then
    echo "Pulling the singularity image for OpenFOAM-11"
    apptainer pull $APPTAINER_IMAGE oras://public.ecr.aws/omnivector-solutions/cfd-openfoam-motorbike:latest
else
    echo "Skipping the image fetch process...we already have the singularity image"
fi


# copy motorBike folder
cp -r $OPENFOAM_DIR/tutorials/incompressibleFluid/motorBike/motorBike .

cd motorBike

# adjust the decompose dict according to the number of processes in the job
nnodes=$SLURM_NNODES
ntasks=$SLURM_NTASKS
ntasks_per_node=$((ntasks / nnodes))
new_subdomains=$ntasks
new_n="($nnodes $ntasks_per_node 1)"
sed -i "s/numberOfSubdomains \+[0-9]\+;/numberOfSubdomains $new_subdomains;/g" system/decomposeParDict
sed -i "s/n \+ (.*);/n $new_n;/g" system/decomposeParDict

apptainer exec --bind $PWD:$HOME $APPTAINER_IMAGE ./Allclean

cp $OPENFOAM_DIR/tutorials/resources/geometry/motorBike.obj.gz constant/geometry/

apptainer exec --bind $PWD:$HOME $APPTAINER_IMAGE blockMesh

apptainer exec --bind $PWD:$HOME $APPTAINER_IMAGE decomposePar -copyZero

mpirun --np $ntasks apptainer exec --bind $PWD:$HOME $APPTAINER_IMAGE snappyHexMesh -overwrite -parallel

find . -type f -iname "*level*" -exec rm {} \;

mpirun --np $ntasks apptainer exec --bind $PWD:$HOME $APPTAINER_IMAGE renumberMesh -overwrite -parallel

mpirun --np $ntasks apptainer exec --bind $PWD:$HOME $APPTAINER_IMAGE potentialFoam -initialiseUBCs -parallel
#!/bin/bash
#SBATCH --partition compute
#SBATCH --nodes=2
#SBATCH --ntasks=2
#SBATCH -J motorbike
#SBATCH --output=/nfs/R-%x.%j.out
#SBATCH --error=/nfs/R-%x.%j.err
#SBATCH -t 1:00:00

# clone OpenFOAM-11 if it is not available yet
OPENFOAM_DIR=/nfs/OpenFOAM-11
if [[ ! -d $OPENFOAM_DIR ]]
then
    echo "Cloning OpenFOAM-11"
    cd /nfs/
    git clone https://github.com/OpenFOAM/OpenFOAM-11
else
    echo "Skipping clone process...we already have the OpenFOAM-11 source code"
fi

# create a working folder inside the shared directory
WORK_DIR=/nfs/$SLURM_JOB_NAME-Job-$SLURM_JOB_ID
mkdir -p $WORK_DIR
cd $WORK_DIR

# path to the openfoam singularity image
export APPTAINER_IMAGE=/nfs/openfoam11.sif

# download the openfoam v11 singularity image if it is not available yet
if [[ ! -f $APPTAINER_IMAGE ]]
then
    echo "Pulling the singularity image for OpenFOAM-11"
    apptainer pull $APPTAINER_IMAGE oras://public.ecr.aws/omnivector-solutions/cfd-openfoam-motorbike:latest
else
    echo "Skipping the image fetch process...we already have the singularity image"
fi


# copy motorBike folder
cp -r $OPENFOAM_DIR/tutorials/incompressibleFluid/motorBike .

# enter motorBike folder
cd motorBike

# clear any previous execution
apptainer exec --bind $PWD:$HOME $APPTAINER_IMAGE ./Allclean

# copy motorBike geometry obj
cp $OPENFOAM_DIR/tutorials/resources/geometry/motorBike.obj.gz constant/geometry/

# define surface features inside the block mesh
apptainer exec --bind $PWD:$HOME $APPTAINER_IMAGE surfaceFeatures

# generate the first mesh
# mesh the environment (block around the model)
apptainer exec --bind $PWD:$HOME $APPTAINER_IMAGE blockMesh

# decomposition of mesh and initial field data
# according to the parameters in decomposeParDict located in the system
# create 6 domains by default
apptainer exec --bind $PWD:$HOME $APPTAINER_IMAGE decomposePar -copyZero

# mesh the motorcicle
# overwrite the new mesh files that are generated
srun apptainer exec --bind $PWD:$HOME $APPTAINER_IMAGE snappyHexMesh -overwrite -parallel

# write field and boundary condition info for each patch
srun apptainer exec --bind $PWD:$HOME $APPTAINER_IMAGE patchSummary -parallel

# potential flow solver
# solves the velocity potential to calculate the volumetric face-flux field
srun apptainer exec --bind $PWD:$HOME $APPTAINER_IMAGE potentialFoam -parallel

# steady-state solver for incompressible turbutent flows
srun apptainer exec --bind $PWD:$HOME $APPTAINER_IMAGE simpleFoam -parallel

# after a case has been run in parallel
# it can be reconstructed for post-processing
apptainer exec --bind $PWD:$HOME $APPTAINER_IMAGE reconstructParMesh -constant
apptainer exec --bind $PWD:$HOME $APPTAINER_IMAGE reconstructPar -latestTime
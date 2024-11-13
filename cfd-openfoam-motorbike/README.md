# Motorbike Aerodynamic Simulation with OpenFOAM

This job script performs an aerodynamic simulation of a motorbike using OpenFOAM, an open-source Computational
Fluid Dynamics (CFD) software package. It leverages Apptainer to encapsulate the OpenFOAM environment, ensuring
reproducibility and simplifying execution on HPC clusters.

## Simulation Steps

The script orchestrates the following steps:

1. **Clone OpenFOAM:** If not already present, the script clones the OpenFOAM-11 source code from GitHub into the
/nfs directory.
2. **Create Working Directory:** A unique working directory is created within the shared /nfs/mnt/motorbike directory.
3. **Fetch Apptainer Image:** The script pulls the pre-built OpenFOAM Apptainer image from a public Amazon ECR
repository if it's not already available locally.
4. **Copy Tutorial Files:** The necessary tutorial files, including the motorBike case setup, are copied from the
OpenFOAM source code directory.
5. **Clean Previous Results:** Any existing results from previous simulations are removed to ensure a clean starting
point.
6. **Copy Geometry:** The motorbike geometry file (motorBike.obj.gz) is copied into the constant/geometry directory
of the case setup.
7. **Generate Mesh:** The blockMesh utility is used to generate the initial mesh for the simulation domain.
8. **Decompose Mesh:** The mesh is decomposed into multiple domains (-copyZero option) for parallel processing.
9. **Mesh Refinement:** The snappyHexMesh utility refines the mesh around the motorbike geometry to capture finer details.
The refinement process is executed in parallel using mpirun.
10. **Remove Intermediate Files:** Intermediate mesh files (*level*) are removed to save storage space.
11. **Renumber Mesh:** The mesh is renumbered (renumberMesh) to optimize parallel efficiency. This step is also performed
in parallel.
12. **Potential Flow Calculation:** The potentialFoam utility solves for the initial velocity potential field,
initializing boundary conditions (-initialiseUBCs) for the subsequent simulation. The calculation is executed in parallel.

## HPC Application

This script utilizes the following HPC application:

* **OpenFOAM:**: A widely-used open-source CFD software package for simulating fluid flow phenomena.

The Apptainer image for OpenFOAM is pre-built with all necessary dependencies and configurations, simplifying
execution and ensuring reproducibility across different HPC environments.

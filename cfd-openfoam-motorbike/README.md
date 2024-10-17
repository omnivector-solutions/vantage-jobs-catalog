# Motorbike Simulation with OpenFOAM

This job script performs an aerodynamic simulation of a motorbike using OpenFOAM, an open-source
computational fluid dynamics (CFD) software package. It leverages Apptainer (formerly Singularity)
to encapsulate the OpenFOAM environment and ensure reproducibility.

## Simulation Steps

The script performs the following steps:

1. **Clone OpenFOAM**: Clones the OpenFOAM-11 source code from GitHub if it's not already available.
2. **Create Working Directory**: Creates a unique working directory within the shared NFS filesystem.
3. **Fetch Apptainer Image**: Downloads the OpenFOAM Apptainer image from an S3 bucket if it doesn't exist.
4. **Load OpenFOAM Environment**: Sources the OpenFOAM environment script to set up necessary variables.
5. **Copy Tutorial Files**: Copies the `motorBike` tutorial files from the OpenFOAM source code.
6. **Clean Previous Results**: Cleans any previous simulation results.
7. **Copy Geometry**: Copies the motorbike geometry file.
8. **Define Surface Features**: Defines surface features for mesh generation.
9. **Generate Mesh**: Generates the mesh for the simulation domain.
10. **Decompose Mesh**: Decomposes the mesh for parallel processing.
11. **Mesh Refinement**: Refines the mesh around the motorbike using `snappyHexMesh`.
12. **Patch Summary**:  Generates a summary of boundary conditions.
13. **Potential Flow Calculation**: Solves for the velocity potential.
14. **Turbulent Flow Simulation**: Performs a steady-state simulation of turbulent flow using `simpleFoam`.
15. **Reconstruct Results**: Reconstructs the simulation results from parallel execution.

## HPC Application

This script utilizes the following HPC application:

* **OpenFOAM:**: A widely-used open-source CFD software package for simulating fluid flow phenomena.

The Apptainer image for OpenFOAM is pre-built with all necessary dependencies and configurations, simplifying
execution and ensuring reproducibility across different HPC environments. For more details regarding the
Apptainer image, check the [Dockerfile](./Dockerfile).
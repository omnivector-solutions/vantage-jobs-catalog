# Benchmark HPL - High-Performance Linpack (HPL)

The HPL (High-Performance Linpack) benchmark is widely used to evaluate the performance of parallel computing systems by measuring their floating-point computation capabilities in FLOPS (Floating-Point Operations Per Second). It solves dense systems of linear equations using LU factorization with partial pivoting.

This project provides a ready-to-use setup to run HPL on a SLURM-managed cluster using containers built on Ubuntu 22.04 with MPI and BLAS libraries.

## Requirements

To properly run this script, the system must meet the following requirements:

- **SLURM:** For job scheduling and resource management.
- **Singularity/Apptainer:** To execute containers.
- **MPI:** For parallel execution.
- **Shared File System:** To store and share data between the compute nodes.

## Simulation Steps

The script orchestrates the following steps:

1. **Create Working Directory:** A unique working directory is created within the shared /nfs/mnt/HPL directory.
2. **Fetch Apptainer Image:** The script pulls the pre-built HPL Apptainer image from a public Amazon ECR repository if it's not already available locally.
3. **Run the Benchmark:** The script executes the HPL benchmark with a pre-configured HPL.dat file inside the Apptainer image.

## HPC Application

This script utilizes the following HPC application:

- **HPL**: A portable implementation of the High-Performance Linpack benchmark for distributed-memory computers. [HPL Documentation](https://www.netlib.org/benchmark/hpl/)

The Apptainer image for HPL is pre-built with all necessary dependencies and configurations, simplifying execution and ensuring reproducibility across different HPC environments.

## Result Interpretation

The main output is stored in the HPL.out file:

- **Gflops**: Performance of the system in billions of operations per second.
- **System** Configuration: Details on matrix size, block size, and process grid.

## Customization

The script offers several customization options:

- **Configuration Parameters**: Editing _HPL.dat_ to modify the default params:

  1. Download the [HPL.dat](https://vantage-public-assets.s3.us-west-2.amazonaws.com/catalog/HPL.dat);
  2. Modify the HPL.dat as needed;
  3. Upload the HPL.dat as a support file.

- **Parallelism**: Update the `--ntasks` (_SBATCH_) and `-np` (_MPIRUN_) values in the JobScript to test different parallel setups.

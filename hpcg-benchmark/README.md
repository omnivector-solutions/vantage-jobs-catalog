# Benchmark HPCG - High-Performance Conjugate Gradient (HPCG)

The HPCG (High-Performance Conjugate Gradient) benchmark is designed to measure the performance of parallel computing systems on workloads that reflect modern scientific computations. It provides insights into memory access patterns, communication, and compute performance.

This project provides a ready-to-use setup to run HPCG on a SLURM-managed cluster using containers built on Ubuntu 22.04 with MPI and necessary libraries.

## Requirements

To properly run this script, the system must meet the following requirements:

- **SLURM:** For job scheduling and resource management.
- **Singularity/Apptainer:** To execute containers.
- **MPI:** For parallel execution.
- **Shared File System:** To store and share data between the compute nodes.

## Simulation Steps

The script orchestrates the following steps:

1. **Create Working Directory:** A unique working directory is created within the shared `/nfs/mnt/hpcg` directory.
2. **Fetch Apptainer Image:** The script pulls the pre-built HPCG Apptainer image from a public Amazon ECR repository if it's not already available locally.
3. **Run the Benchmark:** The script executes the HPCG benchmark with a pre-configured HPCG.dat file inside the Apptainer image.

## HPC Application

This script utilizes the following HPC application:

- **HPCG:** A benchmark designed to complement HPL by addressing a broader set of computational and communication patterns. [HPCG Documentation](https://www.hpcg-benchmark.org)

The Apptainer image for HPCG is pre-built with all necessary dependencies and configurations, simplifying execution and ensuring reproducibility across different HPC environments.

## Result Interpretation

The main output is stored in the `R-HPCG.<job_id>.out` file, located in the working directory created for the job. Key metrics include:

- **Performance:** Measured in GFLOP/s, indicating billions of floating-point operations per second.
- **System Configuration:** Details on problem size, MPI task count, and runtime.

## Customization

The script offers several customization options:

- **Configuration Parameters:** Edit the `HPCG.dat` file to modify the benchmark settings:

  1. Download the [HPCG.dat](https://omnivector-public-assets.s3.us-west-2.amazonaws.com/catalog/HPCG.dat);
  2. Modify the `HPCG.dat` as needed;
  3. Place the customized file in the working directory or bind it during execution.

- **Parallelism:** Update the `--ntasks` (_SBATCH_) and `--np` (_MPIRUN_) values in the JobScript to test with different levels of parallel execution.

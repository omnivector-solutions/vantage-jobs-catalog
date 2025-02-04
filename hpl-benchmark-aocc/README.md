# Benchmark HPL - High-Performance Linpack (HPL) with AMD AOCC Optimization

This version of the HPL (High-Performance Linpack) benchmark leverages AMD's AOCC (AMD Optimizing Compiler) to enhance performance, particularly on AMD architectures. It evaluates the floating-point computation capabilities of parallel computing systems, measuring performance in FLOPS (Floating-Point Operations Per Second). The benchmark solves dense systems of linear equations using LU factorization with partial pivoting.

This project provides an easy-to-use setup to run the HPL benchmark on a SLURM-managed cluster with AMD's AOCc optimization. The setup uses containers built on Ubuntu 22.04, incorporating OpenMP and OpenMPI for parallel execution, along with AMD BLIS for optimized BLAS operations.

## Requirements

To successfully run this script, the following system components are required:

- **SLURM**: For job scheduling and resource management.
- **Singularity/Apptainer**: For container execution.
- **MPI**: For parallel execution of the benchmark.
- **Shared File System**: For storing and sharing data across the compute nodes.

## Simulation Steps

The script follows these steps to execute the benchmark:

1. **Create Working Directory**: A unique working directory is created in the shared `/nfs/mnt/hpl_aocc` directory.
2. **Fetch Apptainer Image**: If the pre-built Apptainer image is not available locally, the script pulls it from a public Amazon ECR repository.
3. **Run the Benchmark**: The script runs the HPL benchmark using the pre-configured HPL.dat file inside the Apptainer container.

## HPC Application

This benchmark utilizes the following HPC applications:

- **HPL**: A portable implementation of the High-Performance Linpack benchmark designed for distributed-memory systems. [HPL Documentation](https://www.netlib.org/benchmark/hpl/) built with the optimized [AOCC](https://www.amd.com/en/developer/aocc.html).

The Apptainer image for HPL is pre-built with AMD AOCC optimizations and other necessary dependencies, ensuring consistent execution and performance across different environments.

## Result Interpretation

Key performance metrics include:

- **Gflops**: The performance of the system, measured in billions of floating-point operations per second.
- **System Configuration**: Details on matrix size, block size, and process grid used during the benchmark.

## Customization

Several options for customization are available to tailor the benchmark to different setups:

- **Configuration Parameters**: You can modify the `HPL.dat` file to adjust parameters such as matrix size, block size, and process grid layout.

  1. Download and edit the [HPL.dat](https://vantage-public-assets.s3.us-west-2.amazonaws.com/catalog/HPL.dat) file.
  2. Customize the parameters as needed.
  3. Upload the modified `HPL.dat` file for use in your benchmark.

- **Parallelism**: Update the `--ntasks` (_SBATCH_) and `-np` (_MPIRUN_) values in the JobScript to test different parallel setups.

## Known Issues

- **Performance Tuning**: The benchmark performance may vary based on system architecture and configuration. AMD-specific optimizations, such as using AOCc and BLIS, should yield improved performance on AMD hardware.

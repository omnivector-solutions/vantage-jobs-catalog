# Benchmark HPCG - High Performance Conjugate Gradient (HPCG) with AMD AOCc Optimization

This version of the HPCG (High Performance Conjugate Gradient) benchmark leverages AMD's AOCc (AMD Optimizing Compiler) to enhance performance on AMD architectures. The HPCG benchmark evaluates the performance of high-performance computing systems, specifically focusing on memory-bound workloads and the use of conjugate gradient methods for solving sparse systems of linear equations.

This project provides a simple-to-use setup to run the HPCG benchmark on a SLURM-managed cluster with AMD's AOCc optimization. The setup uses containers based on Ubuntu 22.04 and leverages OpenMP and OpenMPI for parallel execution, along with AMD-specific optimizations for enhanced performance.

## Requirements

To successfully run this script, the following system components are required:

- **SLURM**: For job scheduling and resource management.
- **Singularity/Apptainer**: For container execution.
- **MPI**: For parallel execution of the benchmark.
- **Shared File System**: For storing and sharing data across compute nodes.

## Simulation Steps

The script follows these steps to execute the benchmark:

1. **Create Working Directory**: A unique working directory is created under `/nfs/mnt/hpcg_oacc/` to store data for the specific job run.
2. **Fetch Apptainer Image**: If the Apptainer image is not available locally, the script pulls it from a public Amazon ECR repository.
3. **Run the Benchmark**: The script runs the HPCG benchmark using the pre-configured `HPCG.dat` file inside the Apptainer container.

## HPC Application

This benchmark utilizes the following HPC applications:

- **HPCG**: A high-performance conjugate gradient solver for evaluating the computational performance of systems on memory-bound problems. [HPCG Documentation](https://www.hpcg-benchmark.org/)

The Apptainer image for HPCG is pre-built with AMD AOCc optimizations and other necessary dependencies, ensuring consistent execution and performance across different environments.

## Result Interpretation

The benchmark generates results stored in the `HPCG.out` file. Key performance metrics include:

- **HPCG performance**: Measured in GFLOP/s, this represents the floating-point operations per second achieved during the conjugate gradient computations.
- **System Configuration**: Details on matrix dimensions and process grid used during the benchmark.

## Customization

Several options for customization are available to tailor the benchmark to different setups:

- **Configuration Parameters**: You can modify the `HPCG.dat` file to adjust parameters such as grid dimensions.

  1. Download and edit the [HPCG.dat](https://vantage-public-assets.s3.us-west-2.amazonaws.com/catalog/HPCG.dat) file.
  2. Customize the parameters as needed.
  3. Upload the modified `HPCG.dat` file for use in your benchmark.

- **Parallelism**: Update the `--ntasks` (_SBATCH_) and `-np` (_MPIRUN_) values in the JobScript to test different parallel setups.

## Known Issues

- **Performance Tuning**: Performance can vary depending on system architecture and configuration. Using AMD-specific optimizations, such as AOCc and BLIS, should result in improved performance on AMD processors.

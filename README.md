# vantage-jobs-catalog
A git store of prepared job scripts that can be imported into Vantage and submitted to a cluster.

## Overview

This repository serves as a centralized catalog of job scripts designed for seamless execution on HPC clusters managed through Vantage. It provides a curated collection of ready-to-use scripts for various common HPC workloads, simplifying job submission and execution using Vantage.

Currently, the following job scripts are available:

* **OpenFOAM Motorbike**: A CFD workflow for simulating the flow around a motorcycle.

## Job Catalog Definition

The job catalog is defined by the `catalog.yaml` file located in the root of this repository. This YAML file provides a structured definition of each available job script, including:

* **Entry Point File**: The primary script responsible for executing the job.
* **Suppoting Files**: Any auxiliary scripts or data files required by the job.
* **Apptainer Image URI**: The URI of the Apptainer image containing the necessary software and dependencies for the job.

## Contributing

Any contribution can start with an issue. Feel free to open a new in case you have a feature request, or even if you found a bug
in any job of the catalog.

New jobs can be added to the repository respecting the following acceptance criteria:

1. The job script folder must have a name that describes the job script it contains, e.g. `cfd-openfoam-motorbike`.
2. The job script folder must contain:
    * A `README.md` file
        a. It must explain the computation that the job script performs.
        b. It must explain the HPC app(s) that the job script uses to run the computation, e.g. OpenFOAM.
        c. It must explain how to examine the results of the job.
    * A job script entrypoint file
        a. It must either be a shell script or a python source file.
        b. It must have a descriptive name.
        c. It must use Apptainer:
            i. It must pull the apptainer image that it needs from our public Apptainer registry (hosted on ECR) to the shared file system at `/nfs`
                * The image name must be prefixed by `vantage-jobs-catalog`.
                * The image name must include the name of the job script folder.
                * Example of the resulting name: `vantage-jobs-catalog-cfd-openfoam-motorbike`.
        d. It must execute its HPC app(s) within the Apptainer container.
    * Any supporting files needed by the job script.
    * An optional `Dockerfile` that can be used to build the Apptainer image.
    * A `metadata.yaml` file that includes:
        a. `summary` (required): A very brief summary describing the catalog entry.
        b. `icon-url` (optional): An icon URL for the catalog entry.
        c. `entrypoint` (entrypoint): The entrypoint job script file.
        d. `supporting-files` (optional): The supporting files for the job script.
        e. `image-source` (optional): The source to use when building the Apptainer image. This may be a `Dockerfile` in the job script folder, a URL to a Docker image hosted somewhere
        f. `image-tags` (optional): The tags to apply to the image upon publication. If omitted, it should be assumed `latest`. Each entry must follow the semantic versioning pattern.

Example:
```yaml
# metadata.yaml
summary: Compute steady flow around a motorcycle
icon-url: ""
entrypoint: job-script.sh
supporting-files: []
image-source: Dockerfile
image-tags:
- "1.0.0"
- "latest"
```

## CLI

The project is integrated with a CLI tool for assisting in the process of building and publishing the artifacts.

The requirements are:
* Python >= 3.12
* Poetry 1.8.0
* Apptainer 1.3.4

Start by installing the dependencies:

```bash
poetry install --only main
```

The entrypoint of the CLI is called by running `poetry run builder`. You can increase the verbosity by adding the
`--verbose` flag, e.g.

```bash
poetry run builder --verbose
```

### Configure the settings

Before building or publishing any artifact, you need to configure a set of settings. To discover what are them, run:

```bash
poetry run builder settings set --help
```

In case you want to use temporary AWS credentials, run the following command to issue them:

```bash
aws sts assume-role --role-arn <role arn> --role-session-name jobCatalogBuilder --no-cli-pager --region us-east-1
```

Substitute the placeholder `<role arn>` for the role you want to assume. Independently if you are assuming a role or using your own credentials, you must have the following AWS permissions:

* **ecr-public:GetAuthorizationToken**
* **ecr-public:DescribeRegistries**
* **ecr-public:GetRepositoryCatalogData**
* **ecr-public:PutImage**
* **ecr-public:UploadLayerPart**
* **ecr-public:CompleteLayerUpload**
* **ecr-public:BatchCheckLayerAvailability**
* **ecr-public:InitiateLayerUpload**
* **s3:UploadFile**
* **s3:PutObjectAcl**

### Build a job script image

To build a job script's Apptainer image, run the following command:

```bash
poetry run builder --verbose apptainer build <job scripts paths>
```

Substitute the `<job scripts paths>` placeholder by the paths of the jobs scripts. You can build more than one
concurrently, e.g.

```bash
poetry run builder --verbose apptainer build ./foo/ ./boo/ ./qux/
```

For development purposes, add a `--dry-run` flag. The entire logic will be run, except the real build process.

### Publish a job script image

To publish a job script's Apptainer image, run the following command:

```bash
poetry run builder --verbose apptainer publish <job scripts paths>
```

Similarly to building the image, substitute the placeholder by passing as many job scripts paths as you need to:

```bash
poetry run builder --verbose apptainer publish ./foo/ ./boo/ ./qux/
```

### Publish a job script artifact

To publish the job script's artifacts to S3, i.e. the entry point and the supporting files, run the command:

```bash
poetry run builder --verbose files publish <job scripts paths>
```

Substitute the placeholder `<job scripts paths>` by the paths of the job scripts whose artifacts will be uploaded.

### Build the `catalog.yaml` file

To build the `catalog.yaml` file, run the command:

```bash
poetry run builder catalog generate
```

A file `catalog.yaml` will be generated at the root of the directory.

## Create the artifact bucket

To create the S3 bucket that will store the job script entry points and supporting files, you need CDK installed.
This deployment is verified with node 22.8.0 and CDK 2.162.1. To create the bucket, run:

```bash
cdk deploy VantageJobsCatalogArtifacts
```

Configure the GitHub repository to use this bucket in automatic deployments using the GitHub CLI and the AWS CLI:

```bash
BUCKET_NAME=$(aws cloudformation list-exports \
--region us-east-1 \
--query 'Exports[?Name==`VantageJobsCatalogArtifactsBucketName`].Value[] | [0]' \
--no-cli-pager \
--output text)
BUCKET_REGION=$(aws cloudformation list-exports \
--region us-east-1 \
--query 'Exports[?Name==`VantageJobsCatalogArtifactsBucketRegion`].Value[] | [0]' \
--no-cli-pager \
--output text)
gh variable set S3_BUCKET --body "$BUCKET_NAME" --repos omnivector-solutions/vantage-jobs-catalog
gh variable set S3_BUCKET_REGION --body "$BUCKET_REGION" --repos omnivector-solutions/vantage-jobs-catalog
```

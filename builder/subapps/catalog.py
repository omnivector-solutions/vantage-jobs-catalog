"""App for managing the catalog.yaml file."""

import typer
import yaml
from loguru import logger

from builder.config import attach_settings
from builder.context import CliContext
from builder.exceptions import handle_abort
from builder.format import render_json, terminal_message
from builder.subapps.helpers import find_job_scripts, load_job_script_metadata

app = typer.Typer()


@app.command(name="generate")
@handle_abort
@attach_settings
def generate_catalog_file(
    ctx: typer.Context,
    dry_run: bool = typer.Option(False, help="Do not generate the catalog file, only print the commands."),
):
    """Generate a catalog.yaml file."""
    ctx_obj = ctx.obj
    assert isinstance(ctx_obj, CliContext)
    settings = ctx_obj.settings
    assert settings is not None

    job_scripts_paths = find_job_scripts()
    logger.debug(f"Found {len(job_scripts_paths)} job scripts: {[path.name for path in job_scripts_paths]}")

    catalog: dict[str, list[dict[str, list[str | None] | list[str] | str | None]]] = {"job-scripts": []}

    for job_script_path in job_scripts_paths:
        metadata = load_job_script_metadata(job_script_path)

        apptainer_image_url: list[str | None]
        if metadata.image_source is None:
            logger.warning(f"No image source found for {job_script_path.name}")
            apptainer_image_url = [None]
        elif metadata.image_source == "Dockerfile":
            if metadata.image_tags is None:
                apptainer_image_url = [
                    f"oras://public.ecr.aws/omnivector-solutions/{job_script_path.name}:latest"
                ]
            else:
                apptainer_image_url = [
                    f"oras://public.ecr.aws/omnivector-solutions/{job_script_path.name}:{tag}"
                    for tag in metadata.image_tags
                ]
        else:
            apptainer_image_url = [metadata.image_source]

        catalog_item = {
            "name": job_script_path.name,
            "summary": metadata.summary,
            "icon-url": metadata.icon_url,
            "description": job_script_path.joinpath("README.md").read_text(),
            "entrypoint-file-url": f"s3://{settings.s3_bucket}/files/{job_script_path.name}/{metadata.entrypoint.name}",
            "supporting-files-urls": [
                f"s3://{settings.s3_bucket}/files/{job_script_path.name}/{supporting_file.name}"
                for supporting_file in metadata.supporting_files
            ]
            if metadata.supporting_files
            else [],
            "apptainer-image-url": apptainer_image_url,
        }
        catalog["job-scripts"].append(catalog_item)
        logger.debug(f"Added {job_script_path.name} to the catalog")

    catalog_path = "catalog.yaml"
    if ctx_obj.verbose:
        logger.debug("Generated catalog:")
        render_json(catalog)

    if not dry_run:
        with open(catalog_path, "w") as catalog_file:
            yaml.dump(catalog, catalog_file, indent=2)

    terminal_message(f"Catalog file generated at {catalog_path}.", "Process Complete")

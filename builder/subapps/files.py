"""App for file related operations, such as upload supporting files to S3."""

import asyncio
from pathlib import Path
from typing import Annotated, Optional

import typer

from builder.config import attach_settings
from builder.context import CliContext
from builder.exceptions import handle_abort
from builder.format import terminal_message
from builder.subapps.helpers import (
    check_metadata_exists,
    find_job_scripts,
    publish_files,
    run_tasks_concurrently,
)

app = typer.Typer()


@app.command(name="publish")
@handle_abort
@attach_settings
def publish(
    ctx: typer.Context,
    job_scripts: Annotated[
        Optional[list[Path]],
        typer.Argument(
            ..., help="Paths of the job scripts to publish. If None, all job scripts will be published."
        ),
    ] = None,
    dry_run: bool = typer.Option(False, help="Do not publish the images, only print the commands."),
):
    """Publish the built Apptainer .sif files for each job script imputed."""
    ctx_obj = ctx.obj
    assert isinstance(ctx_obj, CliContext)
    settings = ctx_obj.settings
    assert settings is not None

    job_scripts = find_job_scripts(job_scripts)

    check_metadata_exists(job_scripts)
    tasks = [publish_files(job_script_path, settings, dry_run) for job_script_path in job_scripts]
    asyncio.run(run_tasks_concurrently(tasks))
    terminal_message(
        f"Published auxiliary files to the bucket {settings.s3_bucket}",
        "Process Complete",
    )

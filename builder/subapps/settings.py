"""App for managing configuration settings commands."""

import typer

from builder.cache import init_cache
from builder.config import attach_settings, clear_settings, dump_settings, init_settings
from builder.exceptions import handle_abort
from builder.format import render_json

app = typer.Typer()


@app.command(name="set")
@init_cache
def set_config(
    aws_access_key_id: str = typer.Option(..., help="The access key id used by authenticating against AWS"),
    aws_secret_access_key: str = typer.Option(
        ..., help="The secret access key used by authenticating against AWS"
    ),
    aws_session_token: str = typer.Option(None, help="The session token used by authenticating against AWS"),
    s3_bucket: str = typer.Option(..., help="The S3 bucket where job scripts will be uploaded to"),
    s3_bucket_region: str = typer.Option(..., help="The region of the S3 bucket"),
):
    """Set the configuration for the CLI."""
    settings = init_settings(
        aws_access_key_id=aws_access_key_id,
        aws_secret_access_key=aws_secret_access_key,
        aws_session_token=aws_session_token,
        s3_bucket=s3_bucket,
        s3_bucket_region=s3_bucket_region,
    )
    dump_settings(settings)


@app.command(name="show")
@handle_abort
@init_cache
@attach_settings
def show_config(ctx: typer.Context):
    """Show the current config."""
    render_json(ctx.obj.settings.model_dump())


@app.command(name="clear")
@handle_abort
@init_cache
def clear_config():
    """Show the current config."""
    clear_settings()

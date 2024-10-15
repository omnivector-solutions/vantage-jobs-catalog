"""Main module for the Vantage Jobs Catalog CLI app."""

from __future__ import annotations

import snick
import typer

from builder.context import CliContext
from builder.exceptions import handle_abort
from builder.format import terminal_message
from builder.logging import init_logs
from builder.subapps import apptainer_app, catalog_app, files_app, settings_app

app = typer.Typer(name="Vantage Jobs Catalog")
app.add_typer(settings_app, name="settings")
app.add_typer(apptainer_app, name="apptainer")
app.add_typer(files_app, name="files")
app.add_typer(catalog_app, name="catalog")


@app.callback(invoke_without_command=True)
@handle_abort
def main(
    ctx: typer.Context,
    verbose: bool = typer.Option(False, help="Enable verbose logging to the terminal"),
):
    """Welcome to the Vantage Jobs Catalog CLI!.

    More information can be shown for each command listed below by running it with the
    --help option.
    """
    if ctx.invoked_subcommand is None:
        terminal_message(
            snick.conjoin(
                "No command provided. Please check [bold magenta]usage[/bold magenta]",
                "",
                f"[yellow]{ctx.get_help()}[/yellow]",
            ),
            subject="Need a command",
        )
        raise typer.Exit()

    init_logs(verbose=verbose)
    ctx.obj = CliContext(verbose=verbose)

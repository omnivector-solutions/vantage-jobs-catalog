"""Custom exceptions for the Vantage Jobs Catalog CLI."""

from functools import wraps
from sys import exc_info

import buzz
import snick
import typer
from loguru import logger
from rich import traceback
from rich.console import Console
from rich.panel import Panel

# Enables prettified traceback printing via rich
traceback.install()


class Abort(buzz.Buzz):
    """Custom exception to handle aborting the CLI."""

    def __init__(  # noqa: D107
        self,
        message,
        *args,
        subject=None,
        log_message=None,
        warn_only=False,
        **kwargs,
    ):
        self.subject = subject
        self.log_message = log_message
        self.warn_only = warn_only
        (_, self.original_error, __) = exc_info()
        super().__init__(message, *args, **kwargs)


def handle_abort(func):
    """Return a decorator to handle Abort exceptions."""

    @wraps(func)
    def wrapper(*args, **kwargs):
        try:
            func(*args, **kwargs)
        except Abort as err:
            if not err.warn_only:
                if err.log_message is not None:
                    logger.error(err.log_message)

                if err.original_error is not None:
                    logger.error(f"Original exception: {err.original_error}")

            panel_kwargs = dict()
            if err.subject is not None:
                panel_kwargs["title"] = f"[red]{err.subject}"
            message = snick.dedent(err.message)

            console = Console()
            console.print()
            console.print(Panel(message, **panel_kwargs))
            console.print()
            raise typer.Exit(code=1)

    return wrapper

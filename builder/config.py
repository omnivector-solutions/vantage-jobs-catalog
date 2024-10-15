"""Configuration management for the Vantage Jobs Catalog CLI."""

import json
from functools import wraps
from typing import Optional

import snick
import typer
from loguru import logger
from pydantic import BaseModel, ValidationError

from builder.cache import cache_dir
from builder.exceptions import Abort

settings_path = cache_dir / "builder.json"


class Settings(BaseModel):
    """Settings for the Vantage Jobs Catalog CLI."""

    aws_access_key_id: str
    aws_secret_access_key: str
    aws_session_token: Optional[str] = None
    s3_bucket: str
    s3_bucket_region: str


def init_settings(**settings_values):
    """Initialize the settings object."""
    try:
        logger.debug("Validating settings")
        return Settings(**settings_values)
    except ValidationError as err:
        raise Abort(
            snick.conjoin(
                "A configuration error was detected.",
                "",
                "Details:",
                "",
                f"[red]{err}[/red]",
            ),
            subject="Configuration Error",
            log_message="Configuration error",
        )


def attach_settings(func):
    """Return a decorator to attach settings to the CLI context."""

    @wraps(func)
    def wrapper(ctx: typer.Context, *args, **kwargs):
        try:
            logger.debug(f"Loading settings from {settings_path}")
            settings_values = json.loads(settings_path.read_text())
        except FileNotFoundError:
            raise Abort(
                f"""
                No settings file found at {settings_path}!

                Run the *settings set* sub-command first to establish the settings.
                """,
                subject="Settings file missing!",
                log_message="Settings file missing!",
            )
        logger.debug("Binding settings to CLI context")
        ctx.obj.settings = init_settings(**settings_values)
        return func(ctx, *args, **kwargs)

    return wrapper


def dump_settings(settings: Settings):
    """Dump the settings to a file."""
    logger.debug(f"Saving settings to {settings_path}")
    settings_values = json.dumps(settings.model_dump())
    settings_path.write_text(settings_values)


def clear_settings():
    """Clear the saved settings."""
    logger.debug(f"Removing saved settings at {settings_path}")
    settings_path.unlink(missing_ok=True)

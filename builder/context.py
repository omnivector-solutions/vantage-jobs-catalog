"""Context for the CLI application."""

from typing import Optional

from pydantic import BaseModel

from builder.config import Settings


class CliContext(BaseModel, arbitrary_types_allowed=True):
    """Context model for the CLI application."""

    settings: Optional[Settings] = None
    verbose: bool = False

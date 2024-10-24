"""Core module for defining types."""

from typing import TypeAlias

# type alias for the job script catalog structure
JobScriptCatalog: TypeAlias = dict[str, list[dict[str, list[str | None] | list[str] | str | None]]]

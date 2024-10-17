"""Core module for defining schemas and constants."""

from pathlib import Path

from pydantic import BaseModel, Field


class JobScriptMetadata(BaseModel):
    """Metadata for a job script."""

    summary: str
    icon_url: str | None = Field(None, alias="icon-url")
    entrypoint: Path
    supporting_files: list[Path] | None = Field(None, alias="supporting-files")
    image_source: str | None = Field(None, alias="image-source")
    image_tags: list[str] | None = Field(None, alias="image-tags")

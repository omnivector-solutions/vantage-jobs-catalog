"""Core module for cache related operations."""

from __future__ import annotations

from functools import wraps
from pathlib import Path

from builder.exceptions import Abort

cache_dir: Path = Path.home() / ".local/share/vantage-jobs-catalog"


def init_cache(func):
    """Return a decorator to initialize the cache directory."""

    @wraps(func)
    def wrapper(*args, **kwargs):
        try:
            cache_dir.mkdir(exist_ok=True, parents=True)
            info_file = cache_dir / "info.txt"
            info_file.write_text("This directory is used by Vantage Jobs Catalog CLI for its cache.")
        except Exception:
            raise Abort(
                f"""
                Cache directory {cache_dir} doesn't exist, is not writable, or could not be created.

                Please check your home directory permissions and try again.
                """,
                subject="Non-writable cache dir",
                log_message="Non-writable cache dir",
            )
        return func(*args, **kwargs)

    return wrapper

"""Core module for logging definitions and initializations."""

import sys

from loguru import logger


def init_logs(verbose=False):
    """Initialize logging for the CLI application based on the verbosity."""
    logger.remove()

    if verbose:
        logger.add(sys.stdout, level="DEBUG")

    logger.debug("Logging initialized")

"""Core module for bash command related operations."""

import shlex
import subprocess

from loguru import logger


def run_command(command) -> tuple[str | None, str | None]:
    """Run a command and return the stdout and stderr."""
    proc = subprocess.run(shlex.split(command), stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    (stdout, stderr) = (proc.stdout.decode(), proc.stderr.decode())
    return (stdout, stderr)


def run_command_logged(command):
    """Execute a shell command while logging its output and errors.

    This function runs a given shell command as a subprocess, captures its
    standard output and standard error streams, and logs the output in real-time.
    If the subprocess returns a non-zero exit code, a RuntimeError is raised with
    the last line of the error output.
    """
    logger.debug(f"Issuing subprocess {command=}")
    proc = subprocess.Popen(
        shlex.split(command),
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
    )
    proc_name = proc.args[0]
    last_err_line = ""
    while proc.poll() is None:
        while True:
            stderr_line = proc.stderr.readline().decode()
            if stderr_line:
                last_err_line = stderr_line
                logger.debug(f"Subprocess {proc_name} => {stderr_line}")
            else:
                break
    if proc.returncode != 0:
        raise RuntimeError(f"Subprocess {proc_name} error: {last_err_line}")

#!/usr/bin/env python3
from time import sleep
from subprocess import Popen, PIPE

DOCKER_ARGS = ["--rm"]  # Remove the image once finished
DOCKER_IMAGE = "test-gateway"


def print_status():
    """Run BEFORE assertions for easier debugging"""
    print(
        f"Stdout: {stdout}",
        f"Stderr: {stderr}",
        f"Return Code:{process.returncode}",
        sep="\n",
    )


process = Popen(
    ["docker", "run", *DOCKER_ARGS, DOCKER_IMAGE],
    stdout=PIPE,
    stderr=PIPE,
    universal_newlines=True,
)

sleep(10)  # Give the image a few seconds to run

if process.poll() != None:  # Make sure that the image didn't die
    stdout, stderr = process.communicate()
    print_status()
    raise AssertionError("Image died")

process.terminate()  # It's alive, so let's kill it
process.poll()
stdout, stderr = process.communicate()

print_status()

assert not stderr, "Output to stderr"
assert process.returncode in [143, 1, 0], "Bad exit code"
assert "HTTP server listening" in stdout, "HTTP Server didn't start"

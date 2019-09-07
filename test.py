#!/usr/bin/env python3
from time import sleep
from subprocess import Popen, PIPE

DOCKER_ARGS = ["--rm"]  # Remove the image once finished
DOCKER_IMAGE = "test-gateway"


def print_status():
    """Run BEFORE assertions for easier debugging"""
    print(
        f"Stdout: {stdout}\n",
        f"Stderr: {stderr}\n",
        f"Return Code:{process.returncode}\n",
    )


process = Popen(
    ["docker", "run", *DOCKER_ARGS, DOCKER_IMAGE], stdout=PIPE, stderr=PIPE, text=True
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
assert process.returncode <= 1, "Bad return code"
assert "HTTP server listening" in stdout, "HTTP Server didn't start"

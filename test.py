#!/usr/bin/env python3
from subprocess import run, TimeoutExpired

DOCKER_ARGS = ["--rm"]  # Remove the image once finished
DOCKER_IMAGE = "iot-gateway"

try:
    process = run(
        ["docker", run, *DOCKER_ARGS, DOCKER_IMAGE],
        capture_output=True,
        text=True,
        timeout=10,
    )
except TimeoutExpired:
    timeout = True
else:
    timeout = False

assert not process.stderr, "Output to stderr (bad)"
assert timeout == True, "Image exited for some (bad) reason"
assert "HTTP server listening" in process.stdout, "HTTP Server didn't start"

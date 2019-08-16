#!/bin/sh
DOCKER_CLI_EXPERIMENTAL=enabled
docker buildx create --name IoT-Gateway
docker buildx use IoT-Gateway
docker buildx inspect --bootstrap
docker buildx build --platform linux/amd64,linux/arm64,linux/arm/v7 -t guccionfleek/iot-gateway --push .
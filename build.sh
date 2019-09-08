#!/bin/sh
DOCKER_CLI_EXPERIMENTAL=enabled
docker buildx create --use IoT-Gateway
docker buildx inspect --bootstrap
docker buildx build --platform linux/amd64,linux/arm64,linux/arm/v7,linux/i386 --pull -t guccionfleek/iot-gateway:$(date +%Y-%m-%d) --push .

#!/bin/sh
export DOCKER_CLI_EXPERIMENTAL=enabled
mkdir -p ~/.docker/cli-plugins
echo '{"experimental": "enabled"}' > ~/.docker/config.json
echo '{"experimental":true}' | sudo tee /etc/docker/daemon.json

wget "https://github.com/docker/buildx/releases/download/v0.3.0/buildx-v0.3.0.linux-amd64"
chmod a+x buildx-v0.3.0.linux-amd64
mv ./buildx-v0.3.0.linux-amd64 ~/.docker/cli-plugins/docker-buildx

sudo docker run --privileged linuxkit/binfmt

docker buildx create --use
docker buildx inspect --bootstrap
docker buildx build --platform linux/amd64,linux/arm64,linux/arm/v7,linux/i386 --pull -t guccionfleek/iot-gateway:$(date +%Y-%m-%d) --push .

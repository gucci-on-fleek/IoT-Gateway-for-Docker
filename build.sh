#!/bin/sh
# https://github.com/gucci-on-fleek/IoT-Gateway-for-Docker
export DOCKER_CLI_EXPERIMENTAL=enabled
mkdir -p ~/.docker/cli-plugins
echo '{"experimental":true}' | sudo tee /etc/docker/daemon.json

wget -q "https://github.com/docker/buildx/releases/download/v0.3.1/buildx-v0.3.1.linux-amd64"
chmod a+x buildx-v0.3.1.linux-amd64
mv ./buildx-v0.3.1.linux-amd64 ~/.docker/cli-plugins/docker-buildx

sudo docker run --privileged docker/binfmt:66f9012c56a8316f9244ffd7622d7c21c1f6f28d

docker buildx create --use
docker buildx inspect --bootstrap
docker buildx build --platform linux/amd64,linux/arm64,linux/arm/v7 --pull -t guccionfleek/iot-gateway:$(date +%Y-%m-%d) -t guccionfleek/iot-gateway:latest --push .

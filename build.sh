#!/bin/sh
export DOCKER_CLI_EXPERIMENTAL=enabled
mkdir -p ~/.docker/cli-plugins
echo '{"experimental":true}' | sudo tee /etc/docker/daemon.json

wget "https://github.com/docker/buildx/releases/download/v0.3.1/buildx-v0.3.1.linux-amd64"
chmod a+x buildx-v0.3.1.linux-amd64
mv ./buildx-v0.3.1.linux-amd64 ~/.docker/cli-plugins/docker-buildx

mkdir ./binfmt/
wget https://raw.githubusercontent.com/docker/binfmt/master/binfmt/Dockerfile https://raw.githubusercontent.com/docker/binfmt/master/binfmt/main.go https://raw.githubusercontent.com/docker/binfmt/master/binfmt/etc/binfmt.d/00_linuxkit.conf
sed -i 's|COPY etc/binfmt.d/00_linuxkit.conf|COPY 00_linuxkit.conf|' Dockerfile
docker build --pull -t binfmt .
sudo docker run --privileged binfmt

cd ..
docker buildx create --use
docker buildx inspect --bootstrap
docker buildx build --platform linux/amd64,linux/arm64,linux/arm/v7 --pull -t guccionfleek/iot-gateway:$(date +%Y-%m-%d) -t guccionfleek/iot-gateway:latest --push .

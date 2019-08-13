# IoT Gateway (for Docker)
## What is this?
This is the easiest possible way to run the [Mozilla IoT Gateway](https://iot.mozilla.org/gateway/) on any platform. 

## How to use
### Linux (all architectures)
1. Install Docker
    ```
    curl -fsSL https://get.docker.com -o get-docker.sh | sudo sh
    ```
2. Download the Docker Compose file to the folder where you want to store the server's data
    ```
    curl -fsSL https://github.com/gucci-on-fleek/IoT-Gateway-for-Docker/raw/master/docker-compose.yml -o docker-compose.yml
    ```
3. Start the container in the same folder as `docker-compose.yml`  
    ```
    docker-compose up -d
    ```
4. You're done!

### Windows and macOS
1. Install Docker  
    [https://www.docker.com/products/docker-desktop](https://www.docker.com/products/docker-desktop)

2. Download the Docker Compose file to the folder where you want to store the server's data  
    ```
    curl -fsSL https://github.com/gucci-on-fleek/IoT-Gateway-for-Docker/raw/master/docker-compose-mac-win.yml -o docker-compose.yml
    ```    
3. Start the container in the same folder as `docker-compose.yml`  
    ```
    docker-compose up -d
    ```
4. You're done!

## Advantages over the [official image](https://hub.docker.com/r/mozillaiot/gateway)
### Small
This image uses only 313 MB of disk space. It uses Alpine Linux as the base, and it installs the absolute minimum number of packages. The image clears out all of its temporary files and dev dependencies after being build to reduce its size to the bare minimum. The official image uses 1.54 GB, so this image is 80% smaller.

### Fast
When ran, the gateway takes only 15 seconds from `docker run` invocation until the gateway's webserver is fully operational. The gateway is mainly fast because the Docker image comes with the gateway fully built and ready to run.

### Easy to use
Images for amd64, armv7, and arm64 are prebuild and uploaded to the Docker Hub. A docker-compose file is provides so the image is easy to run.

## Known Issues
- There is no C/C++ compiler installed in the container, so some addons may fail to install. Currently, the only known instance of this issue is the [Date-time Adapter](https://github.com/tomasy/date-time-adapter) due to its reliance on [pyephem](https://pypi.org/project/pyephem/).
- Some devices may not be discovered when running on macOS or Windows. Due to the way that these platforms run their networking, this is difficult to solve. You can try and add some additional ports to the `docker-compose.yml` to solve this issue if you know which port your device communicates with.

## Contributing
Pull Requests are gladly accepted! I would greatly appreciate any changes that increase the speed, reduce the size, or improve the reliability of the image.

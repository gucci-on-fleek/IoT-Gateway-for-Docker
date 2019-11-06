# WebThings Gateway (for Docker)
The easiest possible way to run the [Mozilla WebThings Gateway](https://iot.mozilla.org/gateway/) on any platform. 

## How to use
### Ubuntu/Debian (x86_64, armv7, arm64)
1. Install the required packages
    ```
    sudo apt install --no-install-recommends docker.io docker-compose curl
    ```
2. Create a data directory
    ```
    sudo mkdir -p /srv/iot-gateway && cd /srv/iot-gateway
    ```
3. Download the required files
    ```
    sudo curl -fsSL https://github.com/gucci-on-fleek/IoT-Gateway-for-Docker/raw/master/docker-compose.yml -o docker-compose.yml && sudo docker-compose pull
    ```
4. Run the container
    ```
    sudo docker-compose up -d
    ```

### Linux (all distros, all architectures)
1. Install Docker
    ```
    curl -fsSL https://get.docker.com | sudo sh
    ```
2. Install Docker Compose
    ```
    sudo curl -L "https://github.com/docker/compose/releases/download/latest/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose; sudo chmod +x /usr/local/bin/docker-compose
    ```
3. Download the Docker Compose file to the folder where you want to store the server's data
    ```
    curl -fsSL https://github.com/gucci-on-fleek/IoT-Gateway-for-Docker/raw/master/docker-compose.yml -o docker-compose.yml
    ```
4. Start the container in the same folder as `docker-compose.yml`  
    ```
    docker-compose up -d
    ```

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

## Advantages over the [official image](https://hub.docker.com/r/mozillaiot/gateway)
### Small
This image uses only 233 MB of disk space. It uses Alpine Linux as the base, and it installs the absolute minimum number of packages. The image clears out all of its temporary files and dev dependencies after being build to reduce its size to the bare minimum. The official image uses 1.54 GB, so this image is 80% smaller.

### Fast
When ran, the gateway takes only 15 seconds from `docker run` invocation until the gateway's webserver is fully operational. The gateway is mainly fast because the Docker image comes with the gateway fully built and ready to run.

### Easy to use
Images for amd64, armv7, and arm64 are prebuild and uploaded to the Docker Hub. A docker-compose file is provides so the image is easy to run.

## Known Issues
- There is no C/C++ compiler installed in the container, so some addons may fail to install. Currently, the only known instance of this issue is the [Date-time Adapter](https://github.com/tomasy/date-time-adapter) due to its reliance on [pyephem](https://pypi.org/project/pyephem/).
- Some devices may not be discovered when running on macOS or Windows. Due to the way that these platforms run their networking, this is difficult to solve. You can try and add some additional ports to the `docker-compose.yml` to solve this issue if you know which port your device communicates with.

## Contributing
Pull Requests are gladly accepted! I would greatly appreciate any changes that increase the speed, reduce the size, or improve the reliability of the image.

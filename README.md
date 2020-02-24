# WebThings Gateway (for Docker)
*Small, fast, easy to use, and secure. Docker image to run the [Mozilla WebThings Gateway](https://iot.mozilla.org/gateway/) on all platforms.*

## How to use
### Ubuntu/Debian (x86_64, armv7, arm64)
1. Install the required packages
    ```bash
    sudo apt install --no-install-recommends docker.io docker-compose curl
    ```
2. Create a data directory
    ```bash
    sudo mkdir -p /srv/iot-gateway && cd /srv/iot-gateway
    ```
3. Download the required files
    ```bash
    sudo curl -fsSL https://github.com/gucci-on-fleek/IoT-Gateway-for-Docker/raw/master/docker-compose.yml -o docker-compose.yml && sudo docker-compose pull
    ```
4. Run the container
    ```bash
    sudo docker-compose up -d
    ```

### Linux (all distros, all architectures)
1. Install Docker
    ```bash
    curl -fsSL https://get.docker.com | sudo sh
    ```
2. Install Docker Compose
    ```bash
    sudo curl -L "https://github.com/docker/compose/releases/download/latest/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose; sudo chmod +x /usr/local/bin/docker-compose
    ```
3. Download the Docker Compose file to the folder where you want to store the server's data
    ```bash
    curl -fsSL https://github.com/gucci-on-fleek/IoT-Gateway-for-Docker/raw/master/docker-compose.yml -o docker-compose.yml
    ```
4. Start the container in the same folder as `docker-compose.yml`  
    ```bash
    docker-compose up -d
    ```

### Windows and macOS
1. Install Docker  
    [https://www.docker.com/products/docker-desktop](https://www.docker.com/products/docker-desktop)

2. Download the Docker Compose file to the folder where you want to store the server's data  
    ```bash
    curl -fsSL https://github.com/gucci-on-fleek/IoT-Gateway-for-Docker/raw/master/docker-compose-mac-win.yml -o docker-compose.yml
    ```    
3. Start the container in the same folder as `docker-compose.yml`  
    ```bash
    docker-compose up -d
    ```

## Updating
Because the container is immutable, it cannot be updated from within the gateway. Nevertheless, the container is quite simple to update. Updates are released daily.

### Linux
*(Run all commands from the data directory)*
1. Download the new image
    ```bash
    docker-compose pull
    ```
2. Restart the container to use the new image
    ```bash
    docker-compose down && docker-compose up -d
    ```
3. Remove old versions
    ```bash
    docker rmi $(docker images | awk '/guccionfleek\/iot-gateway\s+<none>\s+[A-z0-9].*$/{print $3}')
    ```

## Advantages over the [official image](https://hub.docker.com/r/mozillaiot/gateway)
### Small
This image uses only 179 MB of disk space. It uses Alpine Linux as the base, and it installs the absolute minimum number of packages. The image clears out all of its temporary files and dev dependencies after being build to reduce its size to the bare minimum. The official image uses 1.54 GB, so this image is 80% smaller.

### Fast
When ran, the gateway takes only 15 seconds from `docker run` invocation until the gateway's webserver is fully operational.

### Easy to use
Images for amd64, armv7, and arm64 are prebuilt and uploaded to the Docker Hub. A `docker-compose` file is provides so the image is easy to run.

### Secure
The entire gateway runs from within a Docker container, so the kernel can enforce security boundaries to prevent any code — malicious or benign — from running outside of the gateway. In addition, all processes in the container run as an ordinary user (not root). Even if an attacker can run code as the gateway user, he cannot modify the container because all of its files are owned by root.

## Known Issues
- There is no C/C++ compiler installed in the container, so some addons may fail to install. Currently, the only known instance of this issue is the [Date-time Adapter](https://github.com/tomasy/date-time-adapter) due to its reliance on [pyephem](https://pypi.org/project/pyephem/).
- Some devices may not be discovered when running on macOS or Windows. Due to the way that these platforms run their networking, this is difficult to solve. You can try and add some additional ports to `docker-compose.yml` to if you know which port your device communicates with.
- arm64 builds tend to be unstable. This is mainly due to poor upstream support by some of the npm modules. I'm running the arm64 build in production so most issues get fixed pretty quickly, but the x86_64 builds tend to be more stable. 

## Contributing
Pull Requests are gladly accepted! I would greatly appreciate any changes that increase the speed, reduce the size, or improve the reliability of the image.

## Licence
All code in this repository is subject to the "Mozilla Public License Version 2.0". Of course, the Docker image contains many components, so this licence _only_ covers the contributions from this repository. In general though, you can use and modify the Docker image as you see fit, however distribution may carry some additional requirements. See [licence.txt](https://github.com/gucci-on-fleek/IoT-Gateway-for-Docker/blob/master/licence.txt) for more information.

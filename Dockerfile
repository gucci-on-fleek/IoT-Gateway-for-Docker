FROM node:8-alpine

RUN apk update && \
    apk add --no-cache \
        build-base \
        ffmpeg \
        git \
        libcap \
        libffi-dev \
        libusb-dev \
        python3 \
        python3-dev \
        python2 \
        python2-dev \
        cmake \
        tini \
        sudo && \
    cd ~ && \
    git clone https://github.com/nanomsg/nanomsg.git && \
    cd nanomsg && \
    mkdir build && \
    cd build && \
    cmake .. && \
    cmake --build . && \
    cmake --build . --target install && \
    cp libnanomsg.so* /lib && \
    cd ~ && \
    python2 -m ensurepip && \
    python3 -m ensurepip && \
    pip2 install git+https://github.com/mozilla-iot/gateway-addon-python#egg=gateway_addon && \
    pip3 install git+https://github.com/mozilla-iot/gateway-addon-python#egg=gateway_addon && \
    pip3 install git+https://github.com/mycroftai/adapt#egg=adapt-parser && \
    git clone --depth 1 --recursive https://github.com/mozilla-iot/intent-parser && \
    git clone --depth 1 --recursive https://github.com/mozilla-iot/gateway && \
    cd gateway && \
    npm config set unsafe-perm true && \
    npm install && \
    /root/gateway/node_modules/.bin/webpack --display errors-only && \
    echo "#!/bin/bash" > ./start.sh && \
    echo "cd /root/gateway" >> ./start.sh && \
    echo "npm run run-only" >> ./start.sh && \
    chmod +x ./start.sh && \
    apk del --purge python3-dev python2-dev build-base cmake && \
    npm prune --production && \
    npm cache clean --force && \
    rm -rf /root/nanomsg && \  
    rm -rf /tmp/*
    
EXPOSE 8080/tcp 4443/tcp
VOLUME /root/.mozilla-iot
ENTRYPOINT ["/sbin/tini", "/bin/sh"]
CMD ["/root/gateway/start.sh"]
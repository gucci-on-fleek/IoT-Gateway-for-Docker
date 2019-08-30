FROM node:8-alpine

RUN apk add --no-cache \
        build-base \
        git \
        libcap \
        libffi-dev \
        libffi \
        libusb-dev \
        libusb \
        python3 \
        python3-dev \
        python2 \
        python2-dev \
        cmake \
        tini \
        shadow && \
    cd ~ && \
    git clone --depth 1 --recursive https://github.com/nanomsg/nanomsg.git && \
    cd nanomsg && \
    mkdir build && \
    cd build && \
    cmake .. && \
    cmake --build . && \
    cmake --build . --target install && \
    cp libnanomsg.so* /lib && \
    rm -rf /root/nanomsg && \
    cd ~ && \
    python2 -m ensurepip && \
    python3 -m ensurepip && \
    pip2 --no-cache-dir install git+https://github.com/mozilla-iot/gateway-addon-python#egg=gateway_addon && \
    pip3 --no-cache-dir install git+https://github.com/mozilla-iot/gateway-addon-python#egg=gateway_addon && \
    pip3 --no-cache-dir install git+https://github.com/mycroftai/adapt#egg=adapt-parser && \
    useradd -create-home --user-group --shell /bin/sh --system gateway && \
    mkdir -p /srv/gateway && \
    cd /srv/gateway && \
    git clone --depth 1 --recursive https://github.com/mozilla-iot/intent-parser && \
    git clone --depth 1 --recursive https://github.com/mozilla-iot/gateway && \
    cd gateway && \
    npm config set unsafe-perm true && \
    npm install && \
    ./node_modules/.bin/webpack --display errors-only && \
    echo "#!/bin/sh" > ./start.sh && \
    echo "cd /srv/gateway/gateway" >> ./start.sh && \
    echo "npm run run-only" >> ./start.sh && \
    chmod a+x ./start.sh && \
    mkdir ./.mozilla-iot && \
    apk del --purge python3-dev python2-dev build-base cmake libffi-dev libusb-dev git shadow && \
    npm prune --production && \
    npm cache clean --force && \
    rm -rf /tmp/*
    
USER gateway:gateway
EXPOSE 8080/tcp 4443/tcp
VOLUME /home/gateway/.mozilla-iot
ENTRYPOINT ["/sbin/tini", "/bin/sh"]
CMD ["/srv/gateway/gateway/start.sh"]
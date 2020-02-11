FROM node:12-alpine

COPY ./safe-chown.c /root/safe-chown.c

RUN apk add --no-cache --virtual build-reqs \
    python3-dev \
    build-base \
    cmake \
    libffi-dev \
    git \
    shadow \ 
    autoconf \
    automake \
    nasm \
    zlib-dev && \
    apk add --no-cache \
    libcap \
    libffi \
    python3 \
    curl \
    tini \
    zlib \
    optipng \
    libpng && \
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
    gcc -Wall safe-chown.c && \
    mv a.out /bin/safe-chown && \
    chmod u+s,a-w /bin/safe-chown && \
    git clone --depth 1 --recursive https://github.com/pagekite/PyPagekite && \
    git clone --depth 1 --recursive https://github.com/pagekite/PySocksipyChain && \
    cp -R ~/PyPagekite/pagekite /usr/lib/python3*/site-packages/ && \
    cp -R ~/PySocksipyChain/sockschain /usr/lib/python3*/site-packages/ && \
    python3 -m ensurepip && \
    pip3 --no-cache-dir install git+https://github.com/mozilla-iot/gateway-addon-python#egg=gateway_addon && \
    useradd --create-home --user-group --shell /bin/sh --system --uid 4545 gateway && \
    cd /srv && \
    git clone --depth 1 --recursive https://github.com/mozilla-iot/gateway && \
    cd gateway && \
    rm pagekite.py && \
    ln -s /usr/lib/python3*/site-packages/pagekite/__main__.py /srv/gateway/pagekite.py && \
    npm config set unsafe-perm true && \
    npm install imagemin-webpack-plugin && \
    npm install && \
    npm audit fix ; \
    ./node_modules/.bin/webpack --display errors-only && \
    mkdir -p /home/gateway/.mozilla-iot && \
    chown -R gateway:gateway /home/gateway/ && \
    rm -rf /var/cache/apk/* && \
    rm -rf /srv/gateway/src && \
    find /srv/gateway/static -type f -not -name 'floorplan.svg' -delete && \
    find / -type f -name '*.py[co]' -delete -o -type d -name __pycache__ -delete && \
    apk del --purge build-reqs ; \
    npm dedupe && \
    npm prune --production && \
    npm cache clean --force && \
    rm -rf ~/* && \
    rm -rf /tmp/*

COPY ./start.sh /srv/gateway/start.sh
USER gateway:gateway
EXPOSE 8080/tcp 4443/tcp
VOLUME /home/gateway/.mozilla-iot
WORKDIR /srv/gateway
ENTRYPOINT ["/sbin/tini"]
CMD ["/bin/sh", "/srv/gateway/start.sh"]
HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 CMD curl -LkfsS https://localhost:4443 >/dev/null || exit 1

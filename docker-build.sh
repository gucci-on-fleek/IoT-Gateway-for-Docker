#!/bin/sh

   ###########################################################
   #           WebThings Gateway (for Docker)                 #
   # https://github.com/gucci-on-fleek/IoT-Gateway-for-Docker #
   ############################################################

set -e
cd ~

install_packages () {
    apk add --no-cache --virtual build-reqs \
        python3-dev \
        build-base \
        python2 \
        libffi-dev \
        git \
        shadow \
        autoconf \
        automake \
        nasm \
        zlib-dev \
        libpng-dev \
        libjpeg-turbo-dev \
        libtool
    apk add --no-cache \
        libcap \
        libffi \
        python3 \
        curl \
        tini \
        zlib \
        libjpeg-turbo \
        libpng
    python3 -m ensurepip
    pip3 --no-cache-dir install git+https://github.com/mozilla-iot/gateway-addon-python#egg=gateway_addon
}

build_safe_chown () {
    gcc -Wall safe-chown.c
    mv a.out /bin/safe-chown
    chmod u+s,a-w /bin/safe-chown
}

install_pagekite () {
    git clone --depth 1 --recursive https://github.com/pagekite/PyPagekite
    git clone --depth 1 --recursive https://github.com/pagekite/PySocksipyChain 
    cp -R ~/PyPagekite/pagekite /usr/lib/python3*/site-packages/
    cp -R ~/PySocksipyChain/sockschain /usr/lib/python3*/site-packages/
}

prepare_gateway_build () {
    cd /srv/
    git clone --depth 1 --recursive https://github.com/mozilla-iot/gateway.git
    cd gateway
    sed -i 's/"segfault-handler":.*//' package.json
    sed -i 's/.*SegfaultHandler.*//' src/app.js
    rm pagekite.py
    ln -s /usr/lib/python3*/site-packages/pagekite/__main__.py /srv/gateway/pagekite.py 
    npm config set unsafe-perm true
}

install_npm_packages () {
    cd /srv/gateway/
    npm install imagemin-webpack-plugin
    npm install
    npm audit fix || true
}

build_gateway () {
    cd /srv/gateway/
    ./node_modules/.bin/webpack --display errors-only || true
}

create_conf_dir () {
    useradd --create-home --user-group --shell /bin/sh --system --uid 4545 gateway
    mkdir -p /home/gateway/.mozilla-iot && \
    chown -R gateway:gateway /home/gateway/
}

cleanup_node () {
    cd /srv/gateway/
    npm dedupe && \
    rm -rf ./node_modules/gifsicle ./node_modules/mozjpeg ./node_modules/optipng-bin
    npm prune --production
    npm cache clean --force
}

cleanup () {
    rm -rf /var/cache/apk/* && \
    find / -type f -name '*.py[co]' -delete -o -type d -name __pycache__ -delete && \
    apk del --purge build-reqs || true
    ln -s /usr/bin/python3 /usr/bin/python
    rm -rf /var/tmp/* ~/* /tmp/*
}

printf '   ╔═══════════════════════════════════╗\n   ║                                   ║\r   ║   Running %s \n   ╚═══════════════════════════════════╝\n' $1
$1

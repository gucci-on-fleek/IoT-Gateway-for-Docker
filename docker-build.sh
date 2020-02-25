#!/bin/sh

###########################################################
#           WebThings Gateway (for Docker)                 #
# https://github.com/gucci-on-fleek/IoT-Gateway-for-Docker #
############################################################

# This script is to be run only from the Dockerfile. See the url above for more info.

set -e # Fail the entire build if any command fails
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
        libtool \
        libjpeg-turbo-utils \
        gifsicle \
        optipng \
        pngquant \
        jq
    apk add --no-cache \
        libcap \
        libffi \
        python3 \
        curl \
        tini \
        zlib
    python3 -m ensurepip
    pip3 --no-cache-dir install git+https://github.com/mozilla-iot/gateway-addon-python#egg=gateway_addon # Python package to enable python addons
}

build_safe_chown () {
    gcc -Wall safe-chown.c
    mv a.out /bin/safe-chown
    chmod u+s,a-w /bin/safe-chown # Add the 'suid' bit so non-root users can run
}

install_pagekite () {
    git clone --depth 1 --recursive https://github.com/gucci-on-fleek/PyPagekite # We need to install pagekite from master because none of the releases support python3
    git clone --depth 1 --recursive https://github.com/pagekite/PySocksipyChain 
    cp -R ~/PyPagekite/pagekite /usr/lib/python3*/site-packages/
    cp -R ~/PySocksipyChain/sockschain /usr/lib/python3*/site-packages/
}

prepare_gateway_build () {
    cd /srv/
    git clone --depth 1 --recursive https://github.com/mozilla-iot/gateway.git
    cd gateway
    sed -i 's/"segfault-handler":.*//' package.json # segfault-handler is incompatible with musl, therefore it cannot be used under Alpine Linux
    sed -i 's/.*SegfaultHandler.*//' src/app.js
    rm pagekite.py
    ln -s /usr/lib/python3*/site-packages/pagekite/__main__.py /srv/gateway/pagekite.py 
    npm config set unsafe-perm true # Required for arm builds for some reason
}

get_version () { # Gets the version of a package from 'package-lock.json'
    jq -r '..|objects|."'"$1"'"//empty' < package-lock.json | head -n -1 | jq -r '.version'
}

install_image_binaries () { # Install the image binaries using the versions from the package manager instead of building from source each time
    cd /srv/gateway/
    npm install -D --ignore-scripts \
        gifsicle@$(get_version gifsicle) \
        jpegtran-bin@$(get_version jpegtran-bin) \
        mozjpeg@$(get_version mozjpeg) \
        optipng-bin@$(get_version optipng-bin) \
        pngquant-bin@$(get_version pngquant-bin) # Download, but do not install
    mkdir -p ./node_modules/gifsicle/vendor/ ./node_modules/jpegtran-bin/vendor/ ./node_modules/mozjpeg/vendor/ ./node_modules/optipng-bin/vendor/ ./node_modules/pngquant-bin/vendor/
    ln -s $(which gifsicle) ./node_modules/gifsicle/vendor/gifsicle # Add the version from the package manager to the node_modules directory
    ln -s $(which jpegtran) ./node_modules/jpegtran-bin/vendor/jpegtran
    ln -s $(which cjpeg) ./node_modules/mozjpeg/vendor/cjpeg
    ln -s $(which optipng) ./node_modules/optipng-bin/vendor/optipng
    ln -s $(which pngquant) ./node_modules/pngquant-bin/vendor/pngquant-bin
    npm rebuild > /dev/null # Now we build the modules
}


install_npm_packages () {
    cd /srv/gateway/
    npm install -D imagemin-webpack-plugin # Build fails unless installed first
    npm install
    npm audit fix || true # NPM packages tend to have security vulnerabilities, so lets fix them
}

build_gateway () {
    cd /srv/gateway/
    ./node_modules/.bin/webpack --display errors-only
}

create_conf_dir () {
    useradd --create-home --user-group --shell /bin/sh --system --uid 4545 gateway # Create the gateway user
    mkdir -p /home/gateway/.mozilla-iot && \
    chown -R gateway:gateway /home/gateway/
}

cleanup_node () {
    cd /srv/gateway/
    rm -rf ./node_modules/gifsicle/./node_modules/jpegtran-bin/ ./node_modules/mozjpeg ./node_modules/optipng-bin ./node_modules/pngquant-bin/ # Fixes the arm builds
    npm dedupe # Sometimes this can reduce package sizes
    npm prune --production
    npm cache clean --force
}

cleanup () {
    rm -rf /var/cache/apk/* 
    find / -type f -name '*.py[co]' -delete -o -type d -name __pycache__ -delete # The pycache files are quite large and can be rebuild when they are used
    find / -type d -name '.git' -delete # .git directories are large and useless in production
    apk del --purge build-reqs || true
    ln -s /usr/bin/python3 /usr/bin/python
    rm -rf /var/tmp/* ~/* /tmp/*
}

printf '   ╔═══════════════════════════════════╗\n   ║                                   ║\r   ║   Running %s \n   ╚═══════════════════════════════════╝\n' "$1"
$1

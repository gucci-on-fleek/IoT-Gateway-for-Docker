#!/bin/sh

############################################################
#           WebThings Gateway (for Docker)                 #
# https://github.com/gucci-on-fleek/IoT-Gateway-for-Docker #
############################################################

# This script is to be run only from the Dockerfile. See the url above for more info.

set -e # Fail the entire build if any command fails
cd ~

install_packages () {
    apk -q add --no-cache --virtual build-reqs \
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
    apk -q add --no-cache \
        npm \
        libcap \
        libffi \
        python3 \
        curl \
        tini \
        zlib
    python3 -m ensurepip
    pip3 --no-cache-dir install git+https://github.com/WebThingsIO/gateway-addon-python#egg=gateway_addon # Python package to enable python addons
}

build_safe_chown () {
    gcc -Wall safe-chown.c
    mv a.out /usr/local/bin/safe-chown
    chmod a=rx /usr/local/bin/safe-chown
    setcap cap_chown+ep /usr/local/bin/safe-chown
}

install_pagekite () {
    git clone --depth 1 --recursive https://github.com/gucci-on-fleek/PyPagekite.git
    git clone --depth 1 --recursive https://github.com/pagekite/PySocksipyChain 
    cp -R ~/PyPagekite/pagekite /usr/lib/python3*/site-packages/
    cp -R ~/PySocksipyChain/sockschain /usr/lib/python3*/site-packages/
}

prepare_gateway_build () {
    cd /srv/
    git clone --depth 1 --recursive https://github.com/WebThingsIO/gateway.git
    cd gateway
    sed -i 's/"segfault-handler":.*//' package.json # segfault-handler is incompatible with musl, therefore it cannot be used under Alpine Linux
    sed -i 's/.*SegfaultHandler.*//' src/app.js
    rm pagekite.py
    ln -s /usr/lib/python3*/site-packages/pagekite/__main__.py /srv/gateway/pagekite.py 
    npm config set unsafe-perm true # Required for arm builds for some reason
    gcc -dumpspecs | sed -e '/cc1plus:$/a-w' -e '/cc1:$/a-w' | sed -e '/^-w/{N; s/\n/ /;}' > /usr/lib/gcc/$(gcc -dumpmachine)/$(gcc -dumpversion)/specs # Quiet the gcc warnings, there's nothing that we can do about them anyways
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
    npm install
    npm audit fix || true # NPM packages tend to have security vulnerabilities, so lets fix them
}

build_gateway () {
    cd /srv/gateway/
    npm run build
}

create_conf_dir () {
    useradd --create-home --user-group --shell /bin/sh --system --uid 4545 gateway # Create the gateway user
    mkdir -p /home/gateway/.webthings && \
    ln -s /home/gateway/.webthings /home/gateway/.mozilla-iot
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
    find / -path '*/.git*' -delete  -o -name '*.md' -delete -o -name '*.js.map' -delete -o -name '*.h' -delete -o -type f -name '*.py[co]' -delete -o -type d -name __pycache__ -delete  # Delete large, useless files
    find /srv/ -type f -executable -o -name '*.so*' | xargs file | awk -F: '/ELF/ {print $1}' | xargs strip --strip-unneeded || true # Strip all binaries.
    apk -q del --purge build-reqs || true
    ln -s /usr/bin/python3 /usr/bin/python
    rm -rf /var/tmp/* ~/* /tmp/* /var/cache/apk/*
}

printf '   (%s)\n   ╔═══════════════════════════════════╗\n   ║                                   ║\r   ║   Running %s \n   ╚═══════════════════════════════════╝\n' "$(uname -m)" "$1"
$1

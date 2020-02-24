FROM node:12-alpine

LABEL url="https://github.com/gucci-on-fleek/IoT-Gateway-for-Docker"
LABEL description="A Dockerfile for the Mozilla WebThings Gateway. See url."

COPY ./safe-chown.c /root/safe-chown.c
COPY ./docker-build.sh /bin/docker-build

RUN \
    set -e ; \
    docker-build install_packages ; \
    docker-build build_safe_chown ; \
    docker-build install_pagekite ; \
    docker-build prepare_gateway_build ; \
    docker-build install_image_binaries ; \
    docker-build install_npm_packages ; \
    docker-build build_gateway ; \
    docker-build create_conf_dir ; \
    docker-build cleanup_node ; \
    docker-build cleanup

COPY ./start.sh /srv/gateway/start.sh
USER gateway:gateway
EXPOSE 8080/tcp 4443/tcp
VOLUME /home/gateway/.mozilla-iot
WORKDIR /srv/gateway
ENTRYPOINT ["/sbin/tini"]
CMD ["/bin/sh", "/srv/gateway/start.sh"]
HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 CMD curl -LkfsS https://localhost:4443 >/dev/null || exit 1

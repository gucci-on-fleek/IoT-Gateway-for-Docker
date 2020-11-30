#!/bin/sh
# https://github.com/gucci-on-fleek/IoT-Gateway-for-Docker
/usr/local/bin/safe-chown
cd /srv/gateway
npm run run-only

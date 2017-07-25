#!/usr/bin/env bash

certbot certonly \
    --config /opt/certbot/config.ini \
    --webroot \
    --dry-run

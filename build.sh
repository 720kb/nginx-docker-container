#!/bin/bash

docker run \
  --rm \
  -v /usr/local/bin:/target \
  jpetazzo/nsenter && \

docker build \
  --tag 720kb/nginx \
  --force-rm \
  .

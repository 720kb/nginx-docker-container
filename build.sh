#!/bin/bash

mkdir -p nginx-configuration && \

docker build \
  --tag 720kb/nginx \
  --force-rm \
  .

#!/bin/bash

docker run \
--name nginx \
-d \
-h nginx \
-p 0.0.0.0:80:80 \
-p 0.0.0.0:443:443 \
720kb/nginx

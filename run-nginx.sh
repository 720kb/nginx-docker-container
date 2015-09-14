#!/bin/bash

docker run \
--name nginx \
-d \
-h nginx \
--privileged \
-p 0.0.0.0:80:80 \
-p 0.0.0.0:443:443 \
720kb/nginx #&& \

#./add-folder.sh nginx-configuration /opt/nginx-configuration y

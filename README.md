# nginx-docker-container
#### 720kb/nginx


### Usage

    docker pull 720kb/nginx # (soon)


### Building it locally (recommended)

    ./build.sh


### Running it

run it locally via:

    ./run-nginx.sh


then open your browser at <http://localhost/> !  docker magic voodo!

### API (wip)

    ./add-folder.sh <container-dir> <host-dir> # you have to restart it

example:

    ./add-folder.sh ./example/vhosts /opt/nginx-configuration/sites-enabled
    ./add-folder.sh ./example/www /var/www


### Restart

    docker stop nginx
    docker rm nginx2
    docker rename nginx nginx2
    sh ./run-nginx.sh

### xample




### TODO

- push to dockerhub

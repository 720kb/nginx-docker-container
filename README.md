# nginx-docker-container
#### 720kb/nginx


### Usage

    docker pull 720kb/nginx # (soon)


### Building it locally (recommended)

    sh ./build.sh


### Running it

run it locally via:

    sh ./run-nginx.sh
    

then open your browser at <http://localhost/> !  docker magic voodo!

### API (wip)

    ./add-folder.sh <container-dir> <host-dir> # you have to restart it
    
    
### Restart

    docker rename nginx nginx2
    docker rm nginx2
    sh ./run-nginx.sh


zpakka!

### TODO

- push to dockerhub

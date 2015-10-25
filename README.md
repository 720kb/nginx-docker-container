# nginx-docker-container
This is a container that contains a customized nginx installation with also the capability to add folder without shutting down the container.

nginx-docker-container is developed by [720kb](http://720kb.net).

## Requirements
This container needs at least docker v1.8.

## Usage
Download the image from hub.docker.com:
```sh
  $ docker pull 720kb/nginx
```
Then you can run nginx issuing:
```sh
  docker run \
  --name nginx \
  -d \
  -h nginx \
  --privileged \
  -p 0.0.0.0:80:80 \
  -p 0.0.0.0:443:443 \
  720kb/nginx
```
This bounds nginx to ports 80 and 443, with its configuration in `/opt/nginx-configuration` folder inside the container.

If you want to apply your nginx configuration that you already have you should:
1. copy the `add-folder.sh` that is in the `/add-folder` folder (via `docker cp` command) in the host machine;
2. run `./add-folder.sh <your_nginx_conf_folder> /opt/nginx-configuration y`;

and wait a bit.

Now the containerized nginx has your configurations.

To add folders to the container you have to call `./add-folder.sh <your_folder_to_add> <where_you_want_to_put_the_folder_inside_the_container> y`. The only thing to take care is that the folder `<where_you_want_to_put_the_folder_inside_the_container>` must be the same in the site configuration inside the configuration folder.


## Contributing

We will be very grateful if you help us making this project grow up.
Feel free to contribute by forking, opening issues, pull requests etc.

## License

The MIT License (MIT)

Copyright (c) 2014 Dario Andrei, Filippo Oretti

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

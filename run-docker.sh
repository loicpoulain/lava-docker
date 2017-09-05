#!/bin/sh

sudo docker run -it -v /dev:/dev -p 69:69/udp -p 80:80 -p 3079:3079 -p 5555:5555 -p 5556:5556 -h lava-docker --privileged lava-docker

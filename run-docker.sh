#!/bin/sh
sudo docker run -it -v /dev:/dev -v/boot:/boot -v /lib/modules:/lib/modules -p 69:69/udp -p 80:80 -p 3079:3079 -p 5555:5555 -p 5556:5556 -h worker0 --privileged lava-docker


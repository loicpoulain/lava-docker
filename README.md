# Linaro's Automated Validation Architecture (LAVA) Docker Container
Preinstalls and preconfigures the latest LAVA server release.

## Building
To build an image locally, execute the following from the directory you cloned the repo:

```
sudo docker build -t lava-docker .
```

## Running
To run the image from a host terminal / command line execute the following:

```
sudo docker run -it -v /dev:/dev -p 69:69/udp -p 80:80 -p 3079:3079 -p 5555:5555 -p 5556:5556 -h lava-docker --privileged lava-docker
```
Where HOSTNAME is the hostname used during the container build process (check the docker build log), as that is the name used for the worker configuration. You can use `lava-docker` as the pre-built container hostname.

## Additional Setup
In order for TFTP requests to find their way back to the running container, you will need to describe the host IP address to the LAVA master node. You can to create a yaml file on the LAVA master node as described below.

```
echo "dispatcher_ip: <master host ip" > /etc/lava-server/dispatcher.d/<lava-master-hostname>.yaml
```

## Security
default lava user/pass is: admin/admin

Note that this container provides defaults which are unsecure. If you plan on deploying this in a production enviroment please consider the following items:

  * Changing the default admin password
  * Using HTTPS
  
Secure CSRF tokens are disabled as the container uses HTTP by default. To use SSL with this container you will need to remove the following lines from your ```/etc/lava-server/settings.conf```

```
   "CSRF_COOKIE_SECURE": false,
   "SESSION_COOKIE_SECURE": false,
```

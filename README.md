# Linaro's Automated Validation Architecture (LAVA) Docker Container
Preinstalls and preconfigures the latest LAVA server release.

## Building
To build an image locally, execute the following from the directory you cloned the repo:

```
sh build_docker.sh
```

## Running
To run the image from a host terminal / command line execute the following:

```
sh run-docker.sh
```

## Additional Setup
In order for TFTP requests to find their way back to the running container, you will need to describe the host IP address to the LAVA master node.
```
for now you can set your HOST IP in run-docker.sh
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

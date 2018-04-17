#!/bin/bash

echo "TOTO"

postgres-ready () {
  echo "Waiting for lavaserver database to be active"
  while (( $(ps -ef | grep -v grep | grep postgres | grep lavaserver | wc -l) == 0 ))
  do
    echo -n "."
    sleep 1
  done
  echo
  echo "[ ok ] LAVA server ready"
}

start () {
  echo "Starting $1"
  if (( $(ps -ef | grep -v grep | grep -v add_device | grep -v dispatcher-config | grep "$1" | wc -l) > 0 ))
  then
    echo "$1 appears to be running"
  else
    service "$1" start
  fi
}

#remove lava-pid files incase the image is stored without first stopping the services
rm -f /var/run/lava-*.pid 2> /dev/null

echo "dispatcher_ip: ${HOST_IP}" > /etc/lava-server/dispatcher-config/${HOST}.yaml

#start postgresql
#start apache2
#start lava-server
#start lava-master
#start lava-coordinator
#start lava-slave
#start lava-server-gunicorn
#start tftpd-hpa
#start rpcbind
#start nfs-kernel-server

#postgres-ready
#service apache2 reload #added after the website not running a few times on boot
service rpcbind start
service tftpd-hpa start
service postgresql start
service apache2 start
service lava-slave start
service lava-logs start
service lava-publisher start
service lava-server-gunicorn start
service lava-master start

#lava-server manage check --deploy

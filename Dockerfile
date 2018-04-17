FROM debian:stretch-backports

RUN apt -q update && DEBIAN_FRONTEND=noninteractive apt-get -q -y upgrade

RUN DEBIAN_FRONTEND=noninteractive apt-get -q -y install \
    python-django python-django-tables2 wget whiptail gnupg \
    postgresql
RUN service postgresql start && \
    DEBIAN_FRONTEND=noninteractive apt-get -q -y install \
    lava-dispatcher lava-server

RUN a2dissite 000-default
RUN a2enmod proxy
RUN a2enmod proxy_http
RUN a2ensite lava-server.conf
RUN service apache2 restart

# Add services helper utilities to start and stop LAVA
COPY scripts/stop.sh .
COPY scripts/start.sh .

#&& apt-get -y upgrade

#RUN apt-get update && RUN DEBIAN_FRONTEND=noninteractive apt-get install -y




# Install debian packages used by the container
# Configure apache to run the lava server
# Log the hostname used during install for the slave name
#RUN echo 'lava-server   lava-server/instance-name string lava-docker-instance' | debconf-set-selections \
# && echo 'locales locales/locales_to_be_generated multiselect C.UTF-8 UTF-8, en_US.UTF-8 UTF-8 ' | debconf-set-selections \
# && echo 'locales locales/default_environment_locale select en_US.UTF-8' | debconf-set-selections \
# && DEBIAN_FRONTEND=noninteractive install_packages \
# locales \
# postgresql \
# screen \
# sudo \
# wget \
# gnupg \
# vim \
# && service postgresql start \
# && wget http://images.validation.linaro.org/production-repo/production-repo.key.asc \
# && apt-key add production-repo.key.asc \
# && echo 'deb http://images.validation.linaro.org/production-repo/ sid main' > /etc/apt/sources.list.d/lava.list \
# && apt-get clean && apt-get update \
# && DEBIAN_FRONTEND=noninteractive install_packages \
# lava \
# qemu-system \
# qemu-system-arm \
# qemu-system-i386 \
# qemu-kvm \
# e2fsprogs \
# ser2net \
# u-boot-tools \
# python-setproctitle \
# nfs-kernel-server \
# && a2enmod proxy \
# && a2enmod proxy_http \
# && a2dissite 000-default \
# && a2ensite lava-server \
# && /stop.sh

# Create admin user
RUN /start.sh \
    && echo "from django.contrib.auth.models import User; User.objects.create_superuser('admin', 'admin@localhost.com', 'admin')" | lava-server manage shell \
    && /stop.sh

#RUN /start.sh \
#    && sudo lava-server manage workers add worker0 \
#    && lava-server manage device-types add '*' \
#    && lava-server manage devices add --device-type qemu --worker worker0 qemu0 \
#    && /stop.sh

#RUN /start.sh \
# && sudo lava-server manage workers add worker0 \
# && lava-server manage device-types add qemu \
# && lava-server manage devices add --device-type qemu --worker worker0 qemu0 \
# && lava-server manage device-types add beaglebone-black \
 #&& lava-server manage devices add --device-type beaglebone-black --worker worker0 bbb0 \
## && lava-server manage device-types add dragonboard-410c-uboot \
# && lava-server manage devices add --device-type dragonboard-410c-uboot --worker worker0 db410c-uboot0 \
# && /stop.sh

# Change Hostname of the local worker
ARG hostname=worker0
RUN echo HOSTNAME=\"$hostname\" >> /etc/lava-dispatcher/lava-dispatcher.conf

# Add Device Types
COPY configs/device-types/*.jinja2 /etc/lava-server/dispatcher-config/device-types/

# Add Device Dictionnaries
COPY configs/devices/*.jinja2 /etc/lava-server/dispatcher-config/devices/

# NFS export workaround
COPY configs/lava-dispatcher-nfs.exports /etc/exports.d/lava-dispatcher-nfs.exports

# fixed port for rpc.mount
COPY configs/nfs-kernel-server /etc/default/nfs-kernel-server

# TFTP config
COPY configs/tftpd-hpa /etc/default/tftpd-hpa

# Simple relay controller
COPY configs/relay.sh /usr/bin/relay.sh

EXPOSE 69/udp 80 3079 5555 5556

CMD /start.sh && bash

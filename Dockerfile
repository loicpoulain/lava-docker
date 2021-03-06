FROM bitnami/minideb:unstable

# Add services helper utilities to start and stop LAVA
COPY scripts/stop.sh .
COPY scripts/start.sh .

# Install debian packages used by the container
# Configure apache to run the lava server
# Log the hostname used during install for the slave name
RUN echo 'lava-server   lava-server/instance-name string lava-docker-instance' | debconf-set-selections \
 && echo 'locales locales/locales_to_be_generated multiselect C.UTF-8 UTF-8, en_US.UTF-8 UTF-8 ' | debconf-set-selections \
 && echo 'locales locales/default_environment_locale select en_US.UTF-8' | debconf-set-selections \
 && DEBIAN_FRONTEND=noninteractive install_packages \
 locales \
 postgresql \
 screen \
 sudo \
 wget \
 gnupg \
 vim \
 && service postgresql start \
 && wget http://images.validation.linaro.org/production-repo/production-repo.key.asc \
 && apt-key add production-repo.key.asc \
 && echo 'deb http://images.validation.linaro.org/production-repo/ sid main' > /etc/apt/sources.list.d/lava.list \
 && apt-get clean && apt-get update \
 && DEBIAN_FRONTEND=noninteractive install_packages \
 lava \
 qemu-system \
 qemu-system-arm \
 qemu-system-i386 \
 qemu-kvm \
 e2fsprogs \
 ser2net \
 u-boot-tools \
 python-setproctitle \
 nfs-kernel-server \
 && a2enmod proxy \
 && a2enmod proxy_http \
 && a2dissite 000-default \
 && a2ensite lava-server \
 && /stop.sh

# Create a admin user (Insecure note, this creates a default user, username: admin/admin)
RUN /start.sh \
 && echo "from django.contrib.auth.models import User; User.objects.create_superuser('admin', 'admin@localhost.com', 'admin')" | lava-server manage shell \
 && /stop.sh

# Install latest
RUN /start.sh \
 && git clone https://github.com/kernelci/lava-dispatcher.git -b master  /root/lava-dispatcher \
 && cd /root/lava-dispatcher \
 && git checkout release \
 && git clone -b master https://github.com/kernelci/lava-server.git /root/lava-server \
 && cd /root/lava-server \
 && git checkout release \
 && git config --global user.name "Docker Build" \
 && git config --global user.email "info@kernelci.org" \
 && echo "cd \${DIR} && dpkg -i *.deb" >> /root/lava-server/share/debian-dev-build.sh \
 && cd /root/lava-dispatcher && /root/lava-server/share/debian-dev-build.sh -p lava-dispatcher \
 && cd /root/lava-server && /root/lava-server/share/debian-dev-build.sh -p lava-server \
 && /stop.sh

# Add worker0 and devices
RUN /start.sh \
 && sudo lava-server manage workers add worker0 \
 && lava-server manage device-types add qemu \
 && lava-server manage devices add --device-type qemu --worker worker0 qemu0 \
 && lava-server manage device-types add beaglebone-black \
 && lava-server manage devices add --device-type beaglebone-black --worker worker0 bbb0 \
 && lava-server manage device-types add dragonboard-410c-uboot \
 && lava-server manage devices add --device-type dragonboard-410c-uboot --worker worker0 db410c-uboot0 \
 && /stop.sh

# Add device-types
COPY configs/dragonboard-410c-uboot.jinja2 /etc/lava-server/dispatcher-config/device-types/dragonboard-410c-uboot.jinja2

# Add device dictionnaries
COPY configs/qemu0.jinja2 /etc/lava-server/dispatcher-config/devices/qemu0.jinja2
COPY configs/bbb0.jinja2 /etc/lava-server/dispatcher-config/devices/bbb0.jinja2
COPY configs/db410c-uboot0.jinja2 /etc/lava-server/dispatcher-config/devices/db410c-uboot0.jinja2

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

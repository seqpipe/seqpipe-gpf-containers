FROM amd64/ubuntu:18.04 as gpfjs-base

SHELL ["/bin/bash", "-c"]

RUN apt-get update --fix-missing && \
	apt-get install -y build-essential gcc vim wget curl git libgl1-mesa-glx apache2 && \
	apt-get clean

ARG VERSION_TAG

COPY gpfjs-dist-gpf19-${VERSION_TAG}.tar.gz /
COPY gpfjs-dist-gpf38-${VERSION_TAG}.tar.gz /

RUN mkdir -p /site/gpf19 && mkdir -p /site/gpf38

RUN tar zxvf /gpfjs-dist-gpf19-${VERSION_TAG}.tar.gz -C /site/gpf19
RUN tar zxvf /gpfjs-dist-gpf38-${VERSION_TAG}.tar.gz -C /site/gpf38

WORKDIR /site

RUN mkdir -p /var/run/apache2

ENV APACHE_LOG_DIR=/var/log/apache2
ENV APACHE_LOCK_DIR=/var/lock/apache2
ENV APACHE_RUN_GROUP=www-data
ENV APACHE_RUN_DIR=/var/run/apache2
ENV APACHE_RUN_USER=www-data
ENV APACHE_PID_FILE=/var/run/apache2/apache2.pid

RUN a2enmod headers
# RUN a2ensite sparkgpf-gpf19

RUN cat /etc/hostname | awk '{print "ServerName "$1}' >> /etc/apache2/apache2.conf

RUN rm /etc/apache2/sites-enabled/000-default.conf

COPY bin/bootstrap.sh /

CMD ["/bootstrap.sh"]
# CMD ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]

EXPOSE 80

FROM :REGISTRY:/seqpipe-gpf:latest


SHELL ["/bin/bash", "-c"]

RUN apt-get update --fix-missing && \
	apt-get install -y build-essential gcc vim wget curl git libgl1-mesa-glx \
		supervisor less vim \
    	inetutils-ping net-tools apt-utils \
		apache2 && \
		apt-get clean


ARG VERSION_TAG

COPY gpfjs-dist-default-${VERSION_TAG}.tar.gz /

RUN mkdir -p /logs
RUN mkdir -p /site/gpf


RUN tar zxvf /gpfjs-dist-default-${VERSION_TAG}.tar.gz -C /site/gpf

WORKDIR /site

RUN mkdir -p /var/run/apache2

ENV APACHE_LOG_DIR=/var/log/apache2
ENV APACHE_LOCK_DIR=/var/lock/apache2
ENV APACHE_RUN_GROUP=www-data
ENV APACHE_RUN_DIR=/var/run/apache2
ENV APACHE_RUN_USER=www-data
ENV APACHE_PID_FILE=/var/run/apache2/apache2.pid

COPY ./sites-available/localhost.conf /etc/apache2/sites-available/

RUN cat /etc/hostname | awk '{print "ServerName "$1}' >> /etc/apache2/apache2.conf

RUN rm -f /etc/apache2/sites-enabled/000-default.conf

ADD ./supervisor/supervisord.conf /etc/
ADD ./bin/supervisord-bootstrap.sh /
ADD ./bin/wait-for-it.sh /
RUN chmod +x /*.sh

EXPOSE 80 443

# CMD ["/bootstrap.sh"]
# CMD ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]

ENTRYPOINT ["supervisord", "-c", "/etc/supervisord.conf", "-n"]

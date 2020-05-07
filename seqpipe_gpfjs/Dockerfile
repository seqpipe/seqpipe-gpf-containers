FROM amd64/ubuntu:18.04 as node-base

SHELL ["/bin/bash", "-c"]

RUN apt-get update --fix-missing && \
	apt-get install -y build-essential gcc vim wget curl git libgl1-mesa-glx apache2 && \
	apt-get clean

RUN mkdir -p /root/.conda/

RUN wget --quiet https://repo.anaconda.com/archive/Anaconda3-2019.10-Linux-x86_64.sh -O /anaconda.sh && \
    /bin/bash /anaconda.sh -b -p /opt/conda && \
    ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/ && \
    rm /anaconda.sh

RUN /opt/conda/bin/conda init bash

ENV PATH /opt/conda/bin:$PATH

RUN pip install beautifulsoup4

RUN curl -sL https://deb.nodesource.com/setup_10.x | bash -

RUN apt install -y nodejs

RUN mkdir -p /code

WORKDIR /code


FROM node-base as gpfjs

RUN git clone https://github.com/iossifovlab/gpfjs.git

WORKDIR /code/gpfjs


FROM gpfjs as gpf19-build

COPY ./environment.gpf19.ts /code/gpfjs/src/environments/environment.gpf19.ts

RUN npm install

RUN npm run build -- --prod --aot --deploy-url=/gpf19/ --base-href=/gpf19/

RUN python ppindex.py


FROM node-base as package-build

RUN mkdir -p /site

COPY --from=gpf19-build /code/gpfjs/dist/gpfjs /site/gpf19

WORKDIR /site

RUN mkdir -p /var/run/apache2

ENV APACHE_LOG_DIR=/var/log/apache2
ENV APACHE_LOCK_DIR=/var/lock/apache2
ENV APACHE_RUN_GROUP=www-data
ENV APACHE_RUN_DIR=/var/run/apache2
ENV APACHE_RUN_USER=www-data
ENV APACHE_PID_FILE=/var/run/apache2/apache2.pid

COPY ./apache.conf /etc/apache2/sites-available/sparkgpf.conf

COPY ./apache.conf /etc/apache2/sites-enabled/sparkgpf.conf

COPY ./apache-gpf19.conf /etc/apache2/sparkgpf/sparkgpf-gpf19.conf

RUN a2enmod headers

RUN cat /etc/hostname | awk '{print "ServerName "$1}' >> /etc/apache2/apache2.conf

RUN rm /etc/apache2/sites-enabled/000-default.conf

CMD ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]

EXPOSE 80

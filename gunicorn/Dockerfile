FROM seqpipe-anaconda-base

RUN conda create --name gpf && conda install --name gpf -c defaults -c conda-forge -c iossifovlab -c bioconda gpf_wdae

RUN conda install --name gpf -c conda-forge gunicorn mysqlclient

RUN conda install --name gpf -c conda-forge -c anaconda mysql-connector-python

RUN mkdir -p /code/gpf

WORKDIR /code/gpf

RUN git clone https://github.com/iossifovlab/gpf.git

WORKDIR /code/gpf/gpf/wdae

COPY ./start_gunicorn.sh /code/gpf/gpf/wdae/start_gunicorn.sh

COPY ./gpf_index.wsgi /code/gpf/gpf/wdae/wdae/wdae/wsgi.py

COPY ./gpf_index.wsgi /code/gpf/gpf/wdae/wdae/wdae/gunicorn_wsgi.py

COPY ./settings.py /code/gpf/gpf/wdae/wdae/wdae/settings.py

RUN mkdir -p /code/gpf/logs

RUN /opt/conda/envs/gpf/bin/pip install -e /code/gpf/gpf/wdae

COPY ./wdaemanage.py /code/gpf/gpf/wdae/wdae/wdaemanage.py

RUN ln -s /code/gpf/gpf/wdae/wdae/wdaemanage.py /bin/wdaemanage.py

CMD /code/gpf/gpf/wdae/wdae/wdae_bootstrap.sh && /code/gpf/gpf/wdae/start_gunicorn.sh

EXPOSE 9001

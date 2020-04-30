#!/bin/bash

exec /opt/conda/envs/gpf/bin/gunicorn \
    --preload \
    --worker-class gthread \
    --workers=1 \
    --threads=8 \
    --bind=0.0.0.0:9001 \
    --timeout=300 \
    --access-logfile /code/gpf/logs/access.log \
    --error-logfile /code/gpf/logs/error.log \
    wdae.gunicorn_wsgi:application

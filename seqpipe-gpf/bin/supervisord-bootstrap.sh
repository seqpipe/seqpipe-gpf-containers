#!/bin/bash

set -e

for impala_host in ${IMPALA_HOSTS}; do
    echo "waiting for impala on ${impala_host}..."
    /wait-for-it.sh ${impala_host}:25000 -t 300
    echo "done..."
done

/code/wdae/wdae/wdaemanage.py migrate

supervisorctl start gpf

/wait-for-it.sh localhost:9001 -t 240

rc=$?
if [ $rc -ne 0 ]; then
    echo -e "\n---------------------------------------"
    echo -e "  gpf gunicorn not ready! Exiting..."
    echo -e "---------------------------------------"
    exit 1
fi

echo -e "\n\n------------------------------------------------------------------------"
echo -e "gpf gunicorn running..."
echo -e "------------------------------------------------------------------------\n\n"

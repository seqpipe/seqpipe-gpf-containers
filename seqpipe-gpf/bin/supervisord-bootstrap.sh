#!/bin/bash

set -e


/code/wdae/wdae/wdaemanage.py migrate

supervisorctl start gpf19

/wait-for-it.sh localhost:9001 -t 240

rc=$?
if [ $rc -ne 0 ]; then
    echo -e "\n---------------------------------------"
    echo -e "  gpf19 gunicorn not ready! Exiting..."
    echo -e "---------------------------------------"
    exit 1
fi

echo -e "\n\n------------------------------------------------------------------------"
echo -e "gpf19 gunicorn running..."
echo -e "------------------------------------------------------------------------\n\n"

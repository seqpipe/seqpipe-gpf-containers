#!/bin/bash

set -e

for sitename in ${GPF_SITES}; do
    echo "enabling apache site: ${sitename}..."
    a2ensite $sitename
done


/usr/sbin/apache2ctl -D FOREGROUND

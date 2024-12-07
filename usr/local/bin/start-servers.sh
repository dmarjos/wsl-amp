#!/bin/bash

export WHOAMI=`whoami`

export APACHE_STATUS=`sudo ps fax | grep 'apache2' | grep -v 'grep'`
export MYSQL_STATUS=`sudo ps fax | grep 'mysql' | grep -v 'grep'`
export PHP_STATUS=`sudo ps fax | grep 'php-fpm' | grep -v 'grep'`

export APACHE="start"
if [ ! -z "${APACHE_STATUS}" ]; then
    APACHE="restart"
fi

export MYSQL="start"
if [ ! -z "${MYSQL_STATUS}" ]; then
    MYSQL="restart"
fi

export PHP="start"
if [ ! -z "${PHP_STATUS}" ]; then
    PHP="restart"
fi

sudo service apache2 ${APACHE}
sudo service mysql ${MYSQL}
export FPM_PACKAGES=`sudo dpkg -l "php*-fpm" | grep "^ii" | awk '{print $2}'`
for FPM in ${FPM_PACKAGES}; do
    sudo service ${FPM} ${PHP}
done

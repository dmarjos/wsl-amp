#!/bin/bash

export DOMAIN_NAME=`echo $1 | tr '[:upper:]' '[:lower:]'`
export PHP_VERSION=""

shift

if [ ! -z "$1" ]; then
    export PHP_VERSION=$1
    shift
fi

if [ -z "${PHP_VERSION}" ]; then
    export PHP_VERSION=7.4
fi

cd /etc/apache2/sites-available
export CURRENT_PHP_VERSION=`grep "SetHandler" ${DOMAIN_NAME}.conf | grep -oP "php\d{1}.\d{1}"`
sed -i "s/${CURRENT_PHP_VERSION}/php${PHP_VERSION}/g" ${DOMAIN_NAME}.conf
if [ -f ${DOMAIN_NAME}-ssl.conf ]; then
    export CURRENT_PHP_VERSION=`grep "SetHandler" ${DOMAIN_NAME}-ssl.conf | grep -oP "php\d{1}.\d{1}"`
    sed -i "s/${CURRENT_PHP_VERSION}/php${PHP_VERSION}/g" ${DOMAIN_NAME}-ssl.conf
fi

service apache2 restart
export FPM_PACKAGES=`dpkg -l "php*-fpm" | grep "^ii" | awk '{print $2}'`
for FPM in ${FPM_PACKAGES}; do
    service ${FPM} start
done


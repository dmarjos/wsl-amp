#!/bin/bash

export WSLHOSTIP=`ip addr show eth0 | grep 'inet\b' | awk '{print $2}' | cut -d/ -f1`
export DOMAIN_NAME=`echo $1 | tr '[:upper:]' '[:lower:]'`
export PHP_VERSION=""
export USE_SSL=no
#export WORKSPACE={DEFAULT_WORKSPACE}
#export CURRENT_USER={CURRENT_USER}

shift

if [ ! -z "$1" ]; then
    export PHP_VERSION=$1
    shift;
fi

if [ ! -z "$1" -a "$1" == "ssl" ]; then
    export USE_SSL=yes
    shift;
fi

if [ ! -z "$1" -a "$1" == "workspace" -a ! -z "$2" ]; then
    shift;
    export WORKSPACE=$1
    shift;
fi

if [ -z "${PHP_VERSION}" ]; then
    export PHP_VERSION=7.4
fi

install -o dmarjos -g www-data -d /var/www/${WORKSPACE}/${DOMAIN_NAME}

export DOMAIN_ALIASES=$*

cd /etc/apache2/sites-available
cp default-template.conf ${DOMAIN_NAME}.conf
sed -i "s/{DOMAIN_NAME}/${DOMAIN_NAME}/g" ${DOMAIN_NAME}.conf
sed -i "s/{WORKSPACE}/${WORKSPACE}/g" ${DOMAIN_NAME}.conf
sed -i "s/{PHP_VERSION}/${PHP_VERSION}/g" ${DOMAIN_NAME}.conf
if [ ! -z "${DOMAIN_ALIASES}" ]; then
    sed -i "s/{DOMAIN_ALIASES}/${DOMAIN_ALIASES}/g" ${DOMAIN_NAME}.conf
else
    sed -i "/{DOMAIN_ALIASES}/d" ${DOMAIN_NAME}.conf
fi
if [ -f /etc/apache2/sites-enabled/${DOMAIN_NAME}.conf ]; then
    rm -f /etc/apache2/sites-enabled/${DOMAIN_NAME}.conf
fi

ln -s /etc/apache2/sites-available/${DOMAIN_NAME}.conf /etc/apache2/sites-enabled/${DOMAIN_NAME}.conf

if [ "${USE_SSL}" == "yes" ]; then
    cp default-template-ssl.conf ${DOMAIN_NAME}-ssl.conf
    sed -i "s/{DOMAIN_NAME}/${DOMAIN_NAME}/g" ${DOMAIN_NAME}-ssl.conf
    sed -i "s/{PHP_VERSION}/${PHP_VERSION}/g" ${DOMAIN_NAME}-ssl.conf
    if [ ! -z "${DOMAIN_ALIASES}" ]; then
        sed -i "s/{DOMAIN_ALIASES}/${DOMAIN_ALIASES}/g" ${DOMAIN_NAME}-ssl.conf
    else
        sed -i "/{DOMAIN_ALIASES}/d" ${DOMAIN_NAME}-ssl.conf
    fi
    if [ -f /etc/apache2/sites-enabled/${DOMAIN_NAME}-ssl.conf ]; then
	rm -f /etc/apache2/sites-enabled/${DOMAIN_NAME}-ssl.conf
    fi
    ln -s /etc/apache2/sites-available/${DOMAIN_NAME}-ssl.conf /etc/apache2/sites-enabled/${DOMAIN_NAME}-ssl.conf
    mkdir -p ~/openssl
    cd ~/openssl
    openssl req -x509 \
        -sha256 -days 356 \
        -nodes \
        -newkey rsa:2048 \
        -subj "/CN=${DOMAIN_NAME}/C=US/L=San Fransisco" \
        -keyout ${DOMAIN_NAME}-CA.key -out ${DOMAIN_NAME}-CA.crt 

    openssl genrsa -out ${DOMAIN_NAME}.key 2048

    cp default-csr.conf ${DOMAIN_NAME}-csr.conf
    sed -i "s/{DOMAIN_NAME}/${DOMAIN_NAME}/g" ${DOMAIN_NAME}-csr.conf
    sed -i "s/{WSLHOSTIP}/${WSLHOSTIP}/g" ${DOMAIN_NAME}-csr.conf

    cp default-cert.conf ${DOMAIN_NAME}-cert.conf
    sed -i "s/{DOMAIN_NAME}/${DOMAIN_NAME}/g" ${DOMAIN_NAME}-cert.conf

    openssl req -new -key ${DOMAIN_NAME}.key -out ${DOMAIN_NAME}-csr.csr -config ${DOMAIN_NAME}-csr.conf

    openssl x509 -req \
        -in ${DOMAIN_NAME}-csr.csr \
        -CA ${DOMAIN_NAME}-CA.crt -CAkey ${DOMAIN_NAME}-CA.key \
        -CAcreateserial -out ${DOMAIN_NAME}.crt \
	-days 365 \
        -sha256 -extfile ${DOMAIN_NAME}-cert.conf

    cp -f ${DOMAIN_NAME}.crt /etc/ssl/certs/ssl-cert-${DOMAIN_NAME}.crt
    cp -f ${DOMAIN_NAME}.key /etc/ssl/private/ssl-cert-${DOMAIN_NAME}.key
fi
service apache2 restart
export FPM_PACKAGES=`dpkg -l "php*-fpm" | grep "^ii" | awk '{print $2}'`
for FPM in ${FPM_PACKAGES}; do
    service ${FPM} start
done


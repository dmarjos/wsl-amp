#!/bin/bash

export WSLHOSTIP=`ip addr show eth0 | grep 'inet\b' | awk '{print $2}' | cut -d/ -f1`
export DOMAIN_NAME=`echo $1 | tr '[:upper:]' '[:lower:]'`

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

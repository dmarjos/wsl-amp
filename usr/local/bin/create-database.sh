#!/bin/bash
# Save this file as /usr/local/bin/create-database.sh
export DBNAME=$1
export USERNAME=$2
export PASSWORD=$3
if [ -z "${DBNAME}" ]; then
    echo "database name not present";
    exit;
fi
if [ -z "${USERNAME}" ]; then
    echo "user name not present";
    exit;
fi
cat > ~/create_db.sql << EOF
create database ${DBNAME};
create user '${USERNAME}'@'%' identified with 'mysql_native_password' by '${PASSWORD}';
grant all privileges on ${DBNAME}.* to '${USERNAME}'@'%' with grant option;
EOF
if [ -z "${PASSWORD}" ]; then
     sed -i "/create user/d" ~/create_db.sql;
fi
cat ~/create_db.sql | mysql -u root
rm -f ~/create_db.sql

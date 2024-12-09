#!/bin/bash
echo '/***************************************************************\'
echo '| Windows Subsystem for Linux - WEB Development Container Setup |'
echo '|                                                               |'
echo '| This setup script will install and prepare your system to run |'
echo '| your development environment                                  |'
echo '|                                                               |'
echo '| Press CTRL+C to cancel this set up procedure                  |'
echo '\***************************************************************/'
read
export CURRENT_USER=`whoami`
export CURRENT_GROUP=`id -gn`

> ~/wsl-setup.log
if [ "${CURRENT_USER}" == "root" ]; then
	echo "Please do not run this script as root."
	exit
fi

echo -n "Please enter the default workspace name [html]: "
read DEFAULT_WORKSPACE
if [ -z "${DEFAULT_WORKSPACE}" ]; then
	export DEFAULT_WORKSPACE=html
fi
sed -i "/#set workspace/d" usr/local/bin/add-virtual-host.sh
sed -i "s/#export WORKSPACE={DEFAULT_WORKSPACE}/#export WORKSPACE={DEFAULT_WORKSPACE}\nexport WORKSPACE=${DEFAULT_WORKSPACE} #set workspace/g" usr/local/bin/add-virtual-host.sh
sed -i "/#set current user/d" usr/local/bin/add-virtual-host.sh
sed -i "s/#export CURRENT_USER={CURRENT_USER}/#export CURRENT_USER={CURRENT_USER}\nexport CURRENT_USER=${CURRENT_USER} #set current user/g" usr/local/bin/add-virtual-host.sh

echo -n "Please enter the MySQL global user name [super]: "
read DB_SUPER_USER
if [ -z "${DB_SUPER_USER}" ]; then
	export DB_SUPER_USER=super
fi
echo -n "Please enter the MySQL global user password [super]: "
read DB_SUPER_PASSWORD
if [ -z "${DB_SUPER_PASSWORD}" ]; then
	export DB_SUPER_PASSWORD=super
fi

if [ ! -f "/etc/sudoers.d/${CURRENT_USER}" ]; then
	echo 'Setting up SUDO access'
	echo '----------------------'
	echo 'You will be asked to enter your password'
	echo "${CURRENT_USER} ALL=(ALL) NOPASSWD:ALL" > /tmp/sudoers_file 
	sudo install -o root -g root -m 0644 /tmp/sudoers_file /etc/sudoers.d/${CURRENT_USER}
	if [ "$?" == "1" ]; then
		echo "Setting up SUDO access failed. Please verify your password"
		exit
	fi
fi

sudo ./packages-setup.sh ${CURRENT_USER}

export WSL_VERSION="2"
export KERNEL_VERSION=`wslsys | grep 'Linux Kernel'`
if [ -z "${KERNEL_VERSION}" ]; then
	export WSL_VERSION=""
	export KERNEL_VERSION=`wslsys | grep 'WSL Kernel'`
	if [ ! -z "${KERNEL_VERSION}" ]; then 
		if [ -z "`echo "${KERNEL_VERSION}" | grep "WSL2"`" ]; then
			export WSL_VERSION="1"
		else
			export WSL_VERSION="2"
		fi
	fi
fi

echo "WSL Version: ${WSL_VERSION}"
exit

if [ -z "${WSL_VERSION}" ]; then 
	echo "Unable to determine what version of WSL is installed. Aborting"
	exit
fi

if [ "${WSL_VERSION}" == "1" ]; then 
	sudo ./patch-apache2.sh
fi


echo "Setting up container domains"
echo '----------------------------'
cat > ~/.wsl2hosts <<EOF
local.development
EOF

echo 'Installing required folders'
echo '---------------------------'

sudo chown ${CURRENT_USER}:${CURRENT_GROUP} usr/local/bin/*.sh
tar zcf ~/tmp-folder-install.tar.gz etc root usr
cd /
sudo tar zxf ~/tmp-folder-install.tar.gz
rm -f ~/tmp-folder-install.tar.gz

cd -
sudo add-virtual-host.sh local.development 7.4 ssl workspace ${DEFAULT_WORKSPACE}

sudo service apache2 start
sudo service php7.4-fpm start 
sudo service mysql start 

sed "s/{SUPER_USER}/${DB_SUPER_USER}/g" ./init-mysql.sql > ./tmp-init-mysql.sql
sed -i "s/{SUPER_PASSWORD}/${DB_SUPER_PASSWORD}/g" ./tmp-init-mysql.sql
sudo mysql -u root < ./tmp-init-mysql.sql

echo "Cleaning temp files"
echo '-------------------'
rm -f /tmp/sudoers_file
rm -f ./tmp-init-mysql.sql


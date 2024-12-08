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

if [ ! -f /etc/sudoers.d/${CURRENT_USER} ]; then
	echo 'Setting up SUDO access'
	echo '----------------------'
	echo 'You will be asked to enter your password'
	echo "${CURRENT_USER} ALL=(ALL) NOPASSWD:ALL" > /tmp/sudoers_file 
	sudo cp /tmp/sudoers_file /etc/sudoers.d/${CURRENT_USER}
	if [ "$?" == "1" ]; then
		echo "Setting up SUDO access failed. Please verify your password"
		exit
	fi
fi

if [ -z "${GIT_USER_NAME}" -o -z "${GIT_USER_EMAIL}" ]; then
	echo "Please before running this script, run the following command"
	echo ""
	if [ -z "${GIT_USER_NAME}" ]; then
	echo 'export GIT_USER_NAME="Your Name"'
	fi
	if [ -z "${GIT_USER_EMAIL}" ]; then
	echo 'export GIT_USER_EMAIL="your.email@domain.com"'
	fi
	exit
fi
sudo ./packages-setup.sh ${CURRENT_USER}

echo "Setting up container domains"
echo '----------------------------'
cat > ~/.wsl2hosts <<EOF
local.development
EOF

echo 'Installing required folders'
echo '---------------------------'

tar zcf ~/tmp-folder-install.tar.gz etc root usr var
cd /
sudo tar zxf ~/tmp-folder-install.tar.gz
rm -f ~/tmp-folder-install.tar.gz etc root usr var

cd -
sudo add-virtual-host.sh local.development 7.4 ssl workspace ${DEFAULT_WORKSPACE}

WSL_VERSION="2"
KERNEL_VERSION=`wslsys | grep 'Linux Kernel'`
if [ -z "${KERNEL_VERSION}" ]; then
	WSL_VERSION=""
	KERNEL_VERSION=`wslsys | grep 'WSL Kernel'`
	if [ ! -z "${KERNEL_VERSION}" ]; then 
		WSL_VERSION="1"
	fi
fi

if [ "${WSL_VERSION}" == "1" ]; then 
	sudo bash ./patch-apache2.sh
fi

sudo service apache2 start
sudo service php7.4-fpm start 
sudo service mysql start 

sed "s/{SUPER_USER}/${DB_SUPER_USER}/g" ./init-mysql.sql > ./tmp-init-mysql.sql
sed -i "s/{SUPER_PASSWORD}/${DB_SUPER_PASSWORD}/g" ./tmp-init-mysql.sql
sudo mysql -u root < ./temp-init-mysql.sql

echo "Cleaning temp files"
echo '-------------------'
rm -f /tmp/sudoers_file
rm -f ./temp-init-mysql.sql


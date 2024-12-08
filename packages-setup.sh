#!/bin/bash

export CURRENT_USER=$1

echo 'Updating packages'
echo '-----------------'

(apt-get update -y && apt-get upgrade -y) >> /home/${CURRENT_USER}/wsl-setup.log
echo 'Installing required packages'
echo '----------------------------'

apt-get -y install software-properties-common wslu apache2 mc >> /home/${CURRENT_USER}/wsl-setup.log
add-apt-repository ppa:ondrej/php -y  >> /home/${CURRENT_USER}/wsl-setup.log
apt-get -y install php7.4 php7.4-cli php7.4-common php7.4-fpm php7.4-bcmath php7.4-curl php7.4-gd php7.4-intl php7.4-json php7.4-mailparse php7.4-mbstring php7.4-mcrypt php7.4-mysql php7.4-opcache php7.4-readline php7.4-xdebug php7.4-xml php7.4-zip  >> /home/${CURRENT_USER}/wsl-setup.log
apt-get -y install php8.2 php8.2-cli php8.2-common php8.2-fpm php8.2-bcmath php8.2-curl php8.2-gd php8.2-intl php8.2-mailparse php8.2-mbstring php8.2-mcrypt php8.2-mysql php8.2-opcache php8.2-readline php8.2-xdebug php8.2-xml php8.2-zip  >> /home/${CURRENT_USER}/wsl-setup.log
apt-get -y install mysql-server  >> /home/${CURRENT_USER}/wsl-setup.log
a2enmod proxy_fcgi proxy ssl rewrite headers  >> /home/${CURRENT_USER}/wsl-setup.log
sudo update-alternatives --set php /usr/bin/php7.4 
sudo update-alternatives --set phar /usr/bin/phar7.4
sudo update-alternatives --set phar.phar /usr/bin/phar.phar7.4 
EXPECTED_CHECKSUM="$(php -r 'copy("https://composer.github.io/installer.sig", "php://stdout");')"
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
php -r "if (hash_file('sha384', 'composer-setup.php') === '$EXPECTED_CHECKSUM') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
if [ -f composer-setup.php ]; then 
	php composer-setup.php
	php -r "unlink('composer-setup.php');"
fi

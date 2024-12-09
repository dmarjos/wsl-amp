# wsl-amp
A Windows Subsystem for Linux based webserver for development , using Apache, MySQL and PHP

## Requirements:
```
X64: 
Windows 11 23H2 or Higher
```

## Installation of WSL
```
Open “Turn Windows Features on or off”
You need to enable Windows Features before installing any Linux distributions on Windows.
  a) Click on ‘Start‘, search for ‘Turn Windows features on or off‘ –> Open
  b) Scroll down and check
    * Windows Subsystem for Linux
    * Virtual Machine Platform
  c) click "OK"
  d) restart your computer
```

### Updating WSL 

Run PowerShell with elevated privileges (Run as administrator) and type

```
wsl --update --web-download

```
## Installing a Linux distro

Using PowerShell as normal user, install Ubuntu 22.04.5 LTS (or the Ubuntu/Debian based distro of your preference). You can use whatever other base distro you prefer, but you'll need to edit the scripts to use the proper package manager commands (apt for Ubuntu -used by me-, yum for RedHat, etc), or the default configuration files locations 

```
wsl --install Ubuntu-22.04 --web-download
```

## Setting up required software
Once your Linux distro is installed, log in and run
```
sudo apt-get update
sudo apt-get upgrade
sudo apt-get install software-properties-common wslu
```

## Setting up your WSL-AMP web development environment (WDE)

As your normal user, run this command:

```
./wsl-setup.sh
```

This will start the set up process, asking you for all the information required.

## Starting your web development environment

### If you add a new local domain to your WDE
Using elevated Powershell, run this to update your Windows hosts file. 

```
wsl -d Ubuntu-22.04 -- update-hosts.sh
```

### Just to start you daily web development activity

Once you started up your WSL shell, you can just run this
```
sudo start-servers.sh
```

## Command line scripts

*_Do not_* run any of these command line scripts as `root`. 

### add-virtual-host.sh

This script will allow you to created a new virtual host on your WDE. Syntax is as follow

```
sudo add-virtual-host <domain> [PHP_VERSION] [ssl] [workspace <WORKSPACE NAME>] [domain aliases]
```

All of the parameters are positional, and must be present in the specified order. 

PHP_VERSION can be (at this time) 7.4 or 8.2
If you include the [ssl] argument, a self-signed certificate will be created for your local domain 
If you include the [workspace ...] argument, your local domain folder and document root will be created as /var/www/<WORKSPACE NAME>/<domain 

You'll be able to define you default workspace when running the setup script

```
sudo add-virtual-host local.devel-yourdomain.com 7.4 ssl workspace client_1 local.devel-yourdomain.co.uk local.devel-yourdomain.es
```

This will create a new virtual host, prepared to run under PHP 7.4, with a SSL self-signed certificate, under the "client_1" workspace. VirtualHost configuration will be similar to this:

```
<VirtualHost *:80>
    ServerName local.devel-yourdomain.com
	ServerAlias local.devel-yourdomain.co.uk local.devel-yourdomain.es 
    DocumentRoot "/var/www/client_1/local.devel-yourdomain.com"
    ErrorLog /var/log/apache2/local.devel-yourdomain.com_error.log
    CustomLog /var/log/apache2/local.devel-yourdomain.com_access.log combined
    <Directory  "/var/www/client_1/local.devel-yourdomain.com/">
        Options +Indexes +Includes +FollowSymLinks +MultiViews
        AllowOverride All
    </Directory>
    <FilesMatch "\.(cgi|shtml|phtml|php)$">
        SetHandler "proxy:unix:/var/run/php/php7.4-fpm.sock|fcgi://localhost"
    </FilesMatch>
</VirtualHost>

<IfModule mod_ssl.c>
    <VirtualHost *:443>
		ServerName local.devel-yourdomain.com
		ServerAlias local.devel-yourdomain.co.uk local.devel-yourdomain.es 
		
		DocumentRoot "/var/www/client_1/local.devel-yourdomain.com"
        ErrorLog ${APACHE_LOG_DIR}/local.devel-yourdomain.com_error.log
        CustomLog ${APACHE_LOG_DIR}/local.devel-yourdomain.com_access.log combined

        SSLEngine on
        SSLCertificateFile /etc/ssl/certs/ssl-cert-local.devel-yourdomain.com.crt
        SSLCertificateKeyFile /etc/ssl/private/ssl-cert-local.devel-yourdomain.com.key
        <Directory  "/var/www/client_1/local.devel-yourdomain.com/">
            Options +Indexes +Includes +FollowSymLinks +MultiViews
            AllowOverride All
        </Directory>
        <FilesMatch "\.(cgi|shtml|phtml|php)$">
                SSLOptions +StdEnvVars
                SetHandler "proxy:unix:/var/run/php/php7.4-fpm.sock|fcgi://localhost"
        </FilesMatch>
        <Directory /usr/lib/cgi-bin>
                SSLOptions +StdEnvVars
        </Directory>
    </VirtualHost>
</IfModule>
```

### create-database.sh

This script will allow you to create a new MySQL database 

```
sudo create-database.sh dbname <db_user_name> [db_password]
```

This command will create a database under the name *_dbname_*, and it will be assigned to the user *_db_user_name_*. If a password is provided, the user will be created. 

Examples:

```
sudo create-database.sh customers custuser custpassword
```

would be equivalent to running this:

```
sudo mysql -u root
create user custuser@'%' identified with 'mysql_native_password' by 'custpassword';
create database customers;
grant all privileges on customers.* to custuser@'%' with grant option;
```

```
sudo create-database.sh cashflow custuser 
```

would be equivalent to running this:

```
sudo mysql -u root
create database cashflow;
grant all privileges on cashflow.* to custuser@'%' with grant option;
```

This way you will be able to create multiple databases and assign them to the same username

### create-ssl-cert.sh

This script will allow you to create a new self-signed SSL crertificate for a local domain.

```
sudo create-ssl-cert.sh local.devel-yourdomain.com
```


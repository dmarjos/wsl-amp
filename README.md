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

## Command line scripts for web server management

You can run any of these command line scripts as `root`. 

### add-virtual-host.sh

This script will allow you to created a new virtual host on your WDE. Syntax is as follow

```
sudo add-virtual-host {domain} [PHP_VERSION] [ssl] [workspace {WORKSPACE NAME}] [domain aliases]
```

All of the parameters are positional, and must be present in the specified order. 

PHP_VERSION can be (at this time) 7.4 or 8.2
If you include the [ssl] argument, a self-signed certificate will be created for your local domain 
If you include the [workspace ...] argument, your local domain folder and document root will be created as /var/www/{WORKSPACE NAME}/{domain}

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
sudo create-database.sh {dbname} {db_user_name} [db_password]
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

### set-php-version.sh

This script will allow you to change the PHP version under which your domain will be run

```
sudo set-php-version.sh {yourdomain.com} {PHP_VERSION}
```

This will modify the virtualhost configuration file(s) to set the local domain to be served by the specified PHP version. 

## Command line scripts for GIT management on your projects

These scripts were written under the premise that you'll be working on a development team, and multiple development branches will exist on any of your web projects, and each developer can work on different branches that are then merged down into a "master" (either production, staging or UAT) branch. So, when checking out, pulling o pushing from / to branches, the scripts will keep a record on what's the project master branch (`staging`, for example) and what's the current development branch (`BUG-12345-BugDiscoveredByQA`). These master / development branches are kept for each project under the git config variables `devel.masterbranch` / `devel.currentbranch`

### clone-repo.sh

Using this script you'll be able to clone any GIT repository, using HTTPS or SSH urls, and set both the master and development branches record.

```
clone-repo.sh {git_url} [main branch]
```

Some repositories uses "master" as the main branch, other uses "main" or even any other custom branch names.You can specify in the script that main branch's name. If none is specified, the script will assume the main branch is called `master`

For example, if you were to clone this repo you could use

```
clone-repo.sh https://github.com/dmarjos/wsl-amp.git

-or-

clone-repo.sh https://github.com/dmarjos/wsl-amp.git master

-or-

clone-repo git@github.com:dmarjos/wsl-amp.git 

-or-

clone-repo git@github.com:dmarjos/wsl-amp.git master
```

In this case, the script will be equivalent to running this:

```
git clone git@github.com:dmarjos/wsl-amp.git .
git config devel.masterbranch master
git config devel.currentbranch master
```

### checkout-branch.sh

This script allows you to check out a new branch from the current repo. For example, 

```
checkout-branch.sh BUG-7781-AddVirtualHost-Failing
```

would be equivalent to

```
git config devel.currentbranch BUG-7781-AddVirtualHost-Failing
git branch BUG-7781-AddVirtualHost-Failing
git checkout BUG-7781-AddVirtualHost-Failing
git pull origin BUG-7781-AddVirtualHost-Failing
```

### switch-branch.sh

This script allows you to switch to a previously checked out branch on the current repo. For example, 

```
switch-branch.sh feature/wsl-amp2
```

would be equivalent to

```
git config devel.currentbranch feature/wsl-amp2
git checkout feature/wsl-amp2
git pull origin feature/wsl-amp2
```

### pull-site.sh

This script allows you to pull the lates changes on the current branch for the current repo. For example,

```
pull-site.sh
```

would be equivalent to

```
export DEVEL_BRANCH=`git config --get devel.currentbranch`
export MASTER_BRANCH=`git config --get devel.masterbranch`
git pull origin ${MASTER_BRANCH}
git pull origin ${DEVEL_BRANCH}
```

If you get a conflict message on the pull, like 

```
error: Your local changes to the following files would be overwritten by merge:
        usr/local/bin/add-virtual-host.sh
Please commit your changes or stash them before you merge.
Aborting
```

you can try and add the "stash" parameter like this

```
pull-site.sh stash
```

which will be quivalent to 

```
export DEVEL_BRANCH=`git config --get devel.currentbranch`
export MASTER_BRANCH=`git config --get devel.masterbranch`
git stash 
git pull origin ${MASTER_BRANCH}
git pull origin ${DEVEL_BRANCH}
git stash pop
```

### push-site.sh {COMMIT_Message}

This script allows you to push your lates changes on the current branch to the current repo. For example,

```
push-site.sh "#12348 The bug has been fixed"
```

This will be equivalent to 

```
export DEVEL_BRANCH=`git config --get devel.currentbranch`
git add --all
git commit -m "#12348 The bug has been fixed"
git push origin ${DEVEL_BRANCH}
```

### reset-branch.sh

This script allows to completely dimiss any changes that you might have done on the current branch for the current working copy. It's a dangerous script, so be careful. You can lose months of work. Why this script exist? It is useful for me some times, when working with several working copies for the same project, and need to check the different development phases like stage, UAT or production. So, a warning will be displayed and you'll be given the option to continue. 

```
reset-bransh.sh

/***************************************************************\
| Windows Subsystem for Linux - WEB Development Container Setup |
|                                                               |
| This script resets and remove any changes that you might have |
| on the current repository                                     |
|                                                               |
\***************************************************************/
Do you want to continue? (Please type 'Yes, continue'):
```

You will need to type "Yes, continue" to proceed.


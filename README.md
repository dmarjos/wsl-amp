# wsl-amp
A Windows Subsystem for Linux based webserver for development, using Apache, MySQL and PHP

## Requirements:
```
X64: 
Windows 10 22H2
Windows 11 23H2 or Higher
```

## Installation of WSL
```
Open “Turn Windows Features on or off”
You need to enable Windows Features before installing any Linux distributions on Windows.
  a) Click on ‘Start‘, search for ‘Turn Windows features on or off‘ –> Open
  b) Scroll down and check "Windows Subsystem for Linux"
  c) click "OK"
  d) restart your computer
```
## Installing a Linux distro
Using Microsoft Store, install Ubuntu 22.04.5 LTS (or the Ubuntu/Debian based distro of your preference). You can use whatever other base distro you prefer, but you'll need to edit the scripts to use the proper package manager commands (apt for Ubuntu -used by me-, yum for RedHat, etc), or the default configuration files locations 

## Setting up required software
Once your Linux distro is installed, log in and run
```
apt-get update && apt-get upgrade
apt-get install software-properties-common wslu
```

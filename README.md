# wsl-amp
A Windows Subsystem for Linux based webserver for development, using Apache / MySQL and PHP

## Requirements:
X64: 
Windows 10 22H2
Windows 11 23H2 or Higher

## Installation of WSL
Open “Turn Windows Features on or off”
You need to enable Windows Features before installing any Linux distributions on Windows.
  a) Click on ‘Start‘, search for ‘Turn Windows features on or off‘ –> Open
  b) Scroll down and check "Windows Subsystem for Linux"
  c) click "OK"
  d) restart your computer

## Installing a Linux distro
Using Microsoft Store, enable Windows Susbsystem for Linux by installing Ubuntu 22.04.5 LTS (or the Ubuntu/Debian based distro of your preference). 

## Setting up required software
Once your Linux distro is installed, log in and run

apt-get update && apt-get upgrade
apt-get install software-properties-common wslu

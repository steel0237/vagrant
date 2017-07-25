#!/usr/bin/env bash

#/etc/apt/sources.list.d/ondrej-ubuntu-php-xenial.list
#deb http://ppa.launchpad.net/ondrej/php/ubuntu xenial main

sudo su - -c "rm -rf /etc/php/7.1" &>> /dev/null
sudo su - -c "cp -rf /tmp/config/php/ /etc/" &>> /dev/null
sudo su - -c "cp -rf /tmp/config/php/7.1/mods-available/* /etc/php/7.1/cli/conf.d/" &>> /dev/null
sudo su - -c "cp -rf /tmp/config/php/7.1/mods-available/* /etc/php/7.1/fpm/conf.d/" &>> /dev/null
sudo su - -c "rm -rf /etc/nginx/" &>> /dev/null
sudo su - -c "cp -rf /tmp/config/nginx/ /etc/" &>> /dev/null
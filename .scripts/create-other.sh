#!/usr/bin/env bash

#/etc/apt/sources.list.d/ondrej-ubuntu-php-xenial.list
#deb http://ppa.launchpad.net/ondrej/php/ubuntu xenial main

type=$1;
ver=$2;


apt-get install -y mc git dos2unix
ufw disable


/usr/local/bin/composer self-update

if [[ ! -d  /home/ubuntu/run/ ]]; then
mkdir /home/ubuntu/run/
fi

if [[ ! -d /home/ubuntu/log/ ]]; then
mkdir /home/ubuntu/log/
fi

if [[ ! -d /home/ubuntu/tmp/ ]]; then
mkdir /home/ubuntu/tmp/
fi

chown -R ubuntu:ubuntu /home/ubuntu/

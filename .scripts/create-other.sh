#!/usr/bin/env bash

#/etc/apt/sources.list.d/ondrej-ubuntu-php-xenial.list
#deb http://ppa.launchpad.net/ondrej/php/ubuntu xenial main

type=$1;

apt-get install -y $1

if [[ ! -f /usr/bin/git ]]; then
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
fi

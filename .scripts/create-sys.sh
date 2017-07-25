#!/usr/bin/env bash

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

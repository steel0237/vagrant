#!/usr/bin/env bash

if [[ ! -f /usr/sbin/nginx ]]; then

rm -f /etc/nginx/sites-enabled/*
rm -f /etc/nginx/sites-available/*

echo "deb http://nginx.org/packages/ubuntu/ xenial nginx" > /etc/apt/sources.list.d/nginx.list
echo "deb-src http://nginx.org/packages/ubuntu/ xenial nginx" >> /etc/apt/sources.list.d/nginx.list

curl http://nginx.org/keys/nginx_signing.key | apt-key add -

apt-get update && apt-get upgrade -y

apt-get install nginx -y

rm -rf /etc/nginx/
fi
cp -rf /tmp/config/nginx/ /etc/

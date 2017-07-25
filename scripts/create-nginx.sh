#!/usr/bin/env bash

echo "deb http://nginx.org/packages/ubuntu/ xenial nginx" > /etc/apt/sources.list.d/nginx.list
echo "deb-src http://nginx.org/packages/ubuntu/ xenial nginx" >> /etc/apt/sources.list.d/nginx.list

curl http://nginx.org/keys/nginx_signing.key | apt-key add -

apt-get update && apt-get upgrade -y

apt-get install nginx -y

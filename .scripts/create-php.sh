#!/usr/bin/env bash

#/etc/apt/sources.list.d/ondrej-ubuntu-php-xenial.list
#deb http://ppa.launchpad.net/ondrej/php/ubuntu xenial main

type="nts";
ver="7.1.7";

if [[ ! -f /usr/bin/php ]]; then

if [[ $type == "zts" ]]; then
#add-apt-repository -y ppa:ondrej/php-$type
#apt-get update
apt-get install -y libmcrypt-dev pkg-config libssl-dev libxml2 libxml2-dev libcurl4-gnutls-dev libenchant-dev libpq-dev libjpeg-turbo8-dev libpng-dev libfreetype6-dev libpspell-dev libxslt-dev
cd /tmp
wget "https://secure.php.net/get/php-$ver.tar.gz/from/this/mirror" -O php.tar.gz
tar zxvf php.tar.gz
cd php-$ver
./configure --with-config-file-path=/etc/php/7.1/cli --with-config-file-scan-dir=/etc/php/7.1/cli/conf.d  --prefix=/usr/local/php/7.1/ --enable-intl --with-mcrypt --with-pdo-pgsql --with-curl --with-openssl \
--with-zlib --enable-mbstring --enable-ftp --enable-sockets --with-pgsql --enable-pcntl --with-pspell --with-enchant --with-gettext --with-gd --enable-exif --with-jpeg-dir --with-png-dir --with-freetype-dir \
--with-xsl --enable-bcmath --enable-sysvmsg --enable-sysvsem --enable-sysvshm --enable-maintainer-zts --enable-cli --with-tsrm-pthreads --enable-zip
make && make install && make clean


./configure --with-config-file-path=/etc/php/7.1/fpm --with-config-file-scan-dir=/etc/php/7.1/fpm/conf.d  --prefix=/usr/local/php/7.1 --enable-intl --with-mcrypt --with-pdo-pgsql --with-curl --with-openssl \
--with-zlib --enable-mbstring --enable-ftp --enable-sockets --with-pgsql --enable-pcntl --with-pspell --with-enchant --with-gettext --with-gd --enable-exif --with-jpeg-dir --with-png-dir --with-freetype-dir \
--with-xsl --enable-bcmath --enable-sysvmsg --enable-sysvsem --enable-sysvshm --enable-maintainer-zts --with-tsrm-pthreads \
--disable-cli --enable-fpm --with-fpm-user=nginx --with-fpm-group=nginx --enable-zip
make && make install && make clean


ln --symbolic /usr/local/php/7.1/bin/php /usr/bin/php;
ln --symbolic /usr/local/php/7.1/sbin/php-fpm /usr/sbin/php-fpm7.1;

mkdir /run/php/

rm -rf /etc/php/7.1
cp -rf /tmp/config/php/ /etc/

fi


if [[ $type == "nts" ]]; then
add-apt-repository -y ppa:ondrej/php
apt-get update
apt-get install -y pkg-config libssl-dev libxml2 libxml2-dev libcurl4-gnutls-dev libenchant-dev libpq-dev libjpeg-turbo8-dev libpng-dev libfreetype6-dev libpspell-dev libxslt-dev
#apt-get install -y php7.1-fpm=$ver* php7.1-soap php7.1-cli=$ver* php7.1=$ver* php7.1-memcached php7.1-curl php7.1-gmp php7.1-xml php7.1-mbstring php7.1-dev php7.1-igbinary php7.1-imap php7.1-pgsql php7.1-zip php7.1-intl php7.1-gd && update-rc.d php7.1-fpm defaults
apt-get install -y php7.1-fpm php7.1-bcmath php7.1-soap php7.1-cli php7.1 php7.1-memcached php7.1-curl php7.1-gmp php7.1-xml php7.1-mbstring php7.1-dev php7.1-igbinary php7.1-imap php7.1-pgsql php7.1-zip php7.1-intl php7.1-gd && update-rc.d php7.1-fpm defaults

rm -rf /etc/php/7.1
cp -rf /tmp/config/php/ /etc/

fi

curl -s https://getcomposer.org/installer | php
mv composer.phar /usr/local/bin/composer
curl -sSL http://www.phing.info/get/phing-latest.phar > /usr/local/bin/phing
chmod +x /usr/local/bin/phing

fi

cp -rf /tmp/config/php/ /etc/
ln --symbolic /tmp/config/php/7.1/mods-available /etc/php/7.1/fpm/conf.d || true
ln --symbolic /tmp/config/php/7.1/mods-available /etc/php/7.1/cli/conf.d || true


FROM php:7.2.8-apache-stretch

LABEL maintainer="jibo@outlook.com"

RUN apt-get update

# install libs
RUN apt-get install -qqy --allow-unauthenticated --no-install-recommends \
    apache2-dev \
    git \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    libssl-dev \
    vim \
    wget \
    zip unzip

# install graphicsmagick with recommands
RUN apt-get install -qqy --allow-unauthenticated graphicsmagick libgraphicsmagick1-dev

# freetds
# ftp://ftp.freetds.org/pub/freetds/stable/freetds-patched.tar.gz
# ENV: http://www.freetds.org/userguide/envvar.htm
# TDSVER: http://www.freetds.org/userguide/choosingtdsprotocol.htm
# Setting TDS version to 0 for the experimental auto-protocol feature
ENV TDSVER 0
ADD freetds-patched.tar.gz .
RUN cd freetds-1.00.94 \
    && ./configure --prefix=/usr/local \
    && make && make install && make clean \
    && cd .. && rm -rf *
COPY freetds.conf /usr/local/etc/freetds.conf

# install ext within official image
RUN docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-configure pdo_dblib --with-pdo-dblib=/usr/local \
    && docker-php-ext-install \
        gd \
        bcmath \
        mbstring \
        mysqli \
        opcache \
        pcntl \
        pdo_mysql \
        pdo_dblib \
        zip

# gmagick
# https://pecl.php.net/package/gmagick
ADD gmagick-2.0.5RC1.tgz .
RUN cd gmagick-2.0.5RC1 \
    && phpize && ./configure \
    && make && make install && make clean \
    && cd .. && rm -rf *

# memcache
# https://github.com/websupport-sk/pecl-memcache/tree/php7
# commit: beff63f
ADD pecl-memcache-php7.tgz .
RUN cd pecl-memcache-php7 \
    && phpize && ./configure \
    && make && make install && make clean \
    && cd .. && rm -rf *

# redis
# https://pecl.php.net/package/redis
ADD redis-3.1.6.tgz .
RUN cd redis-3.1.6 \
    && phpize && ./configure \
    && make && make install && make clean \
    && cd .. && rm -rf *

# xdebug
# https://pecl.php.net/package/xdebug
ADD xdebug-2.6.1.tgz .
RUN cd xdebug-2.6.1 \
    && phpize && ./configure \
    && make && make install && make clean \
    && cd .. && rm -rf *

COPY php.ini-production /usr/local/etc/php/php.ini

# composer
# https://getcomposer.org/download/
COPY composer-1.6.5.phar /usr/local/bin/composer

# apache
COPY mpm_prefork_default.conf /etc/apache2/mods-available/mpm_prefork.conf
RUN ln -s /etc/apache2/mods-available/rewrite.load /etc/apache2/mods-enabled/rewrite.load

# localization
ENV LANG C.UTF-8
RUN cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && echo "Asia/Shanghai" > /etc/timezone

# sample
ADD http://qiniu.syncxplus.com/logo/testbird.png /var/font/
COPY imagick_type_gen /var/font/
COPY add_font_sample.sh /var/font/
RUN /var/font/add_font_sample.sh
COPY info.php /var/www/html/
COPY gm.php /var/www/html/

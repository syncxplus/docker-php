FROM php:7.1.14-fpm-jessie

LABEL maintainer="jibo@outlook.com"

RUN apt-get update

# install font WenQuanYi-Micro-Hei
RUN apt-get -qqy --no-install-recommends install ttf-wqy-microhei

# install libs
RUN apt-get install -qqy --no-install-recommends \
    ImageMagick \
    libmagick++-dev \
    libmagickcore-dev \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libpng12-dev \
    libssl-dev \
    nginx \
    vim \
    wget \
    zip unzip

# nginx
COPY default /etc/nginx/sites-available/default

# freetds
# ftp://ftp.freetds.org/pub/freetds/stable/freetds-patched.tar.gz
# ENV: http://www.freetds.org/userguide/envvar.htm
# TDSVER: http://www.freetds.org/userguide/choosingtdsprotocol.htm
# Setting TDS version to 0 for the experimental auto-protocol feature
ENV TDSVER 0
ADD freetds-patched.tar.gz .
RUN cd freetds-1.00.80 \
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

# imagick
# https://pecl.php.net/package/imagick
ADD imagick-3.4.3.tgz .
RUN cd imagick-3.4.3 \
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
ADD xdebug-2.6.0.tgz .
RUN cd xdebug-2.6.0 \
    && phpize && ./configure \
    && make && make install && make clean \
    && cd .. && rm -rf *

COPY php.ini-production /usr/local/etc/php/php.ini

# composer
# https://getcomposer.org/download/
COPY composer-1.6.3.phar /usr/local/bin/composer

# localization
ENV LANG C.UTF-8
RUN cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && echo "Asia/Shanghai" > /etc/timezone

# entry
COPY docker-php-entrypoint /usr/local/bin/docker-php-entrypoint
CMD ['docker-php-entrypoint']
EXPOSE 80

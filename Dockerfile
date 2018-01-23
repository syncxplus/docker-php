FROM php:5.6.31-apache

MAINTAINER Bo Ji <jibo@outlook.com>

RUN apt-get update

# install font WenQuanYi-Micro-Hei
RUN apt-get -qqy --no-install-recommends install ttf-wqy-microhei

# install libs
RUN apt-get install -qqy --no-install-recommends \
    curl \
    ImageMagick \
    libmagick++-dev \
    libmagickcore-dev \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libmcrypt-dev \
    libpng12-dev \
    libssl-dev \
    vim \
    wget \
    zip unzip

# install ext within official image
RUN docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/
RUN docker-php-ext-install \
        gd \
        bcmath \
        mbstring \
        mcrypt \
        mysql \
        mysqli \
        opcache \
        pcntl \
        pdo_mysql \
        zip

# imagick
# https://pecl.php.net/package/imagick
ADD imagick-3.4.3.tgz .
RUN cd imagick-3.4.3 \
    && phpize && ./configure \
    && make && make install && make clean \
    && cd .. && rm -rf *

# memcache
# https://pecl.php.net/package/memcache
ADD memcache-2.2.7.tgz .
RUN cd memcache-2.2.7 \
    && phpize && ./configure \
    && make && make install && make clean \
    && cd .. && rm -rf *

# xdebug
# https://pecl.php.net/package/xdebug
ADD xdebug-2.5.5.tgz .
RUN cd xdebug-2.5.5 \
    && phpize && ./configure \
    && make && make install && make clean \
    && cd .. && rm -rf *

COPY php.ini-production /usr/local/etc/php/php.ini

# composer
# https://getcomposer.org/download/
COPY composer-1.4.3.phar /usr/local/bin/composer

# enable apache rewrite
RUN ln -s /etc/apache2/mods-available/rewrite.load /etc/apache2/mods-enabled/rewrite.load

# timezone
RUN cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && echo "Asia/Shanghai" > /etc/timezone

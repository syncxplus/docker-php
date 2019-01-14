FROM php:5.6-apache-stretch

LABEL maintainer=jibo@outlook.com

RUN apt-get update && apt-get install -y --allow-unauthenticated \
     apt-utils apache2-dev git libmcrypt-dev locales openssl vim \
     libgraphicsmagick1-dev libgraphicsmagick++1-dev graphicsmagick \
     libzip-dev zip unzip \
  && apt-get clean && rm -r /var/lib/apt/lists/* \
  && cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
  && echo Asia/Shanghai > /etc/timezone \
  && sed -i 's/# zh_CN.UTF-8 UTF-8/zh_CN.UTF-8 UTF-8/1' /etc/locale.gen \
  && locale-gen

ENV LANG zh_CN.UTF-8

# freetds
# ENV: http://www.freetds.org/userguide/envvar.htm
# TDSVER: http://www.freetds.org/userguide/choosingtdsprotocol.htm
# Setting TDS version to 0 for the experimental auto-protocol feature
ENV TDSVER 0
RUN curl -OL ftp://ftp.freetds.org/pub/freetds/stable/freetds-patched.tar.gz \
  && tar -xzf freetds-patched.tar.gz \
  && cd `ls|grep freetds` \
  && ./configure --prefix=/usr/local \
  && make && make install && make clean \
  && cd .. && rm -rf freetds*
COPY freetds.conf /usr/local/etc/freetds.conf

# extension
RUN docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
  && docker-php-ext-install gd \
  && docker-php-ext-configure pdo_dblib --with-pdo-dblib=/usr/local \
  && docker-php-ext-install pdo_dblib \
  && docker-php-ext-configure zip --with-libzip \
  && docker-php-ext-install zip \
  && docker-php-ext-install bcmath mbstring mcrypt mysql mysqli pdo_mysql opcache pcntl sockets \
  && pecl install gmagick-1.1.7RC3 \
  && pecl install memcache-2.2.7 \
  && pecl install xdebug-2.5.5

# config
COPY docker-php-ext-gmagick.ini docker-php-ext-memcache.ini /usr/local/etc/php/conf.d/
COPY 5.6-apache-stretch/php.ini /usr/local/etc/php/php.ini

# composer
# https://getcomposer.org/download/
RUN curl -o composer-setup.php -L https://getcomposer.org/installer \
  && php composer-setup.php --install-dir=/usr/local/bin --filename=composer \
  && rm -rf composer-setup.php

# font
WORKDIR /var/www/html
COPY add_font_sample.sh gm.php info.php ./
RUN ./add_font_sample.sh && rm -f add_font_sample.sh
RUN chown -R www-data:www-data ./

# apache
COPY 5.6-apache-stretch/mpm_prefork.conf /etc/apache2/mods-available/mpm_prefork.conf
RUN ln -s /etc/apache2/mods-available/rewrite.load /etc/apache2/mods-enabled/rewrite.load

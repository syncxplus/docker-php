FROM php:5.6.38-apache-jessie

LABEL maintainer="jibo@outlook.com"

RUN apt-get update

# install libs
RUN apt-get install -qqy --no-install-recommends \
    ImageMagick \
    libmagick++-dev \
    libmagickcore-dev \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libmcrypt-dev \
    libpng12-dev \
    libssl-dev \
    locales \
    vim \
    zip unzip

# install ext
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
        zip \
    && pecl install imagick-3.4.3 \
    && pecl install memcache-2.2.7 \
    && pecl install xdebug-2.5.5

COPY php.ini /usr/local/etc/php/php.ini
COPY docker-php-ext-imagick.ini docker-php-ext-memcache.ini /usr/local/etc/php/conf.d/

# composer
# https://getcomposer.org/download/
RUN curl -o composer-setup.php -L https://getcomposer.org/installer \
    && php composer-setup.php --install-dir=/usr/local/bin --filename=composer \
    && rm -rf *

# apache
COPY mpm_prefork.conf /etc/apache2/mods-available/mpm_prefork.conf
RUN ln -s /etc/apache2/mods-available/rewrite.load /etc/apache2/mods-enabled/rewrite.load

# localization
RUN cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && echo "Asia/Shanghai" > /etc/timezone \
    && sed -i 's/# zh_CN.UTF-8 UTF-8/zh_CN.UTF-8 UTF-8/1' /etc/locale.gen \
    && locale-gen
ENV LANG zh_CN.UTF-8

# sample
COPY info.php /var/www/html/

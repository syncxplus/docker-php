FROM php:7.2.11-apache-stretch

LABEL maintainer="jibo@outlook.com"

RUN apt-get update && apt-get install -y --allow-unauthenticated \
    graphicsmagick \
    libgraphicsmagick1-dev \
    && apt-get clean && rm -r /var/lib/apt/lists/*

RUN apt-get update && apt-get install -y --allow-unauthenticated --no-install-recommends \
    apache2-dev \
    git \
    libssl-dev \
    locales \
    vim \
    zip unzip \
    && apt-get clean && rm -r /var/lib/apt/lists/*

# freetds
# ENV: http://www.freetds.org/userguide/envvar.htm
# TDSVER: http://www.freetds.org/userguide/choosingtdsprotocol.htm
# Setting TDS version to 0 for the experimental auto-protocol feature
ENV TDSVER 0
RUN curl -OL ftp://ftp.freetds.org/pub/freetds/stable/freetds-patched.tar.gz \
    && tar -xzf freetds-patched.tar.gz \
    && rm -f freetds-patched.tar.gz \
    && cd `ls|grep freetds` \
    && ./configure --prefix=/usr/local \
    && make && make install && make clean \
    && cd .. && rm -rf *
COPY freetds.conf /usr/local/etc/freetds.conf

# install ext
RUN docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-configure pdo_dblib --with-pdo-dblib=/usr/local \
    && docker-php-ext-install \
        bcmath \
        gd \
        mysqli \
        opcache \
        pcntl \
        pdo_mysql \
        pdo_dblib \
        zip \
    && pecl install gmagick-2.0.5RC1 \
    && pecl install xdebug

COPY php.ini /usr/local/etc/php/php.ini
COPY docker-php-ext-gmagick.ini /usr/local/etc/php/conf.d/

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
COPY add_font_sample.sh gm.php info.php /var/www/html/
RUN ./add_font_sample.sh && rm -f add_font_sample.sh && chown -R www-data:www-data /var/www/html

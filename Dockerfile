FROM ubuntu:18.04

LABEL maintainer="Althaia S/A Ind. Farmaceutica <tecnologia@althaia.com.br>"

ENV DEBIAN_FRONTEND=noninteractive

# UPDATE AND INSTALL INITIAL PACKAGES
RUN apt-get update && apt-get install software-properties-common -y && add-apt-repository ppa:ondrej/php -y && apt-get update

# INSTALL PACKAGES
RUN apt-get install -y \
    nginx \
    curl \
    wget \
    vim \
    unzip \
    zip \
    libssl-dev \
    supervisor \
    php7.2-cli \
    php7.2-fpm \
    php7.2-bcmath \
    php7.2-bz2 \
    php7.2-common \
    php7.2-curl \
    php7.2-dba \
    php7.2-dev \
    php7.2-enchant \
    php7.2-gd \
    php7.2-gmp \
    php7.2-imap \
    php7.2-interbase \
    php7.2-intl \
    php7.2-json \
    php7.2-ldap \
    php7.2-mbstring \
    php7.2-mysql \
    php7.2-odbc \
    php7.2-opcache \
    php7.2-pgsql \
    php7.2-phpdbg \
    php7.2-pspell \
    php7.2-readline \
    php7.2-recode \
    php7.2-snmp \
    php7.2-soap \
    php7.2-sqlite3 \
    php7.2-sybase \
    php7.2-tidy \
    php7.2-xml \
    php7.2-xmlrpc \
    php7.2-xsl \
    php7.2-zip \
    php7.2-redis

# INSTALL COMPOSER
RUN curl -s https://getcomposer.org/installer | php && mv composer.phar /usr/local/bin/composer

# INSTALL MSSQL
RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - && \
    curl https://packages.microsoft.com/config/ubuntu/18.04/prod.list > /etc/apt/sources.list.d/mssql-release.list && \
    apt-get update && ACCEPT_EULA=Y apt-get install -y msodbcsql17 && ACCEPT_EULA=Y apt-get install -y mssql-tools && \
    echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bash_profile && \
    echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bashrc && \
    apt-get install unixodbc-dev && apt-get -y install php-pear php7.2-dev && \
    pecl install sqlsrv && pecl install pdo_sqlsrv && \
    echo "extension=sqlsrv.so" > /etc/php/7.2/mods-available/sqlsrv.ini && \
    echo "extension=pdo_sqlsrv.so" > /etc/php/7.2/mods-available/pdo_sqlsrv.ini && \
    ln -s /etc/php/7.2/mods-available/sqlsrv.ini /etc/php/7.2/cli/conf.d/20-sqlsrv.ini && \
    ln -s /etc/php/7.2/mods-available/pdo_sqlsrv.ini /etc/php/7.2/cli/conf.d/20-pdo_sqlsrv.ini && \
    ln -s /etc/php/7.2/mods-available/sqlsrv.ini /etc/php/7.2/fpm/conf.d/20-sqlsrv.ini && \
    ln -s /etc/php/7.2/mods-available/pdo_sqlsrv.ini /etc/php/7.2/fpm/conf.d/20-pdo_sqlsrv.ini

# COPY NGINX CONFIG
COPY nginx/mime.types /etc/nginx/mime.types
COPY nginx/nginx.conf /etc/nginx/nginx.conf

# COPY PHP CONFIGS
COPY php/php.ini /etc/php/7.2/fpm/php.ini
COPY php/php-fpm.conf /etc/php/7.2/fpm/php-fpm.conf
COPY php/www.conf /etc/php/7.2/fpm/pool.d/www.conf
RUN mkdir /var/run/php && mkdir /var/log/php

# COPY CRONTAB CONFIGS
COPY crontabs/crontab /etc/crontab

# COPY SUPERVISOR CONFIG
COPY supervisor/supervisord.conf /etc/supervisord.conf

# CLEAN DIRECTORY AND AJUST PERMISSIONS
RUN rm -Rf /var/www/* && chmod -R 755 /var/www

# DEFINE WORKDIR
WORKDIR /var/www

# FINAL CLEAN UP
RUN apt-get upgrade -y && apt-get autoremove -y && apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    rm /var/log/lastlog /var/log/faillog

# UPDATE USER ACCESS
RUN usermod -u 1000 www-data

# EXPOSE PORTS
EXPOSE 80

# COPY SHELLSCRIPT
COPY scripts/init.sh /scripts/init.sh
RUN chmod +x /scripts/init.sh

# FINAL POINT
ENTRYPOINT ["/scripts/init.sh"]

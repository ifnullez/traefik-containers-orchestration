FROM wordpress:php8.3

# Enable apache modules
RUN a2enmod headers rewrite

# Set timezone in php.ini
# RUN echo "date.timezone=UTC" > /usr/local/etc/php/conf.d/timezone.ini

# Install dependencies
RUN apt-get update && apt-get install -y \
    curl unzip less vim git wget curl \
    python3 python3-dev python3-pip build-essential \
    libz-dev libmemcached-dev zlib1g-dev libssl-dev libzip-dev zip \
    build-essential g++ autoconf libtool pkg-config \
    && rm -rf /var/lib/apt/lists/* \
    && ln -sf python3 /usr/bin/python


# Install Python 2 manually from source
# RUN wget https://www.python.org/ftp/python/2.7.18/Python-2.7.18.tgz \
#     && tar -xvf Python-2.7.18.tgz \
#     && cd Python-2.7.18 \
#     && ./configure --enable-optimizations \
#     && make -j"$(nproc)" \
#     && make altinstall \
#     && ln -sf /usr/local/bin/python2.7 /usr/bin/python2 \
#     && cd .. && rm -rf Python-2.7.18 Python-2.7.18.tgz

# Install WP-CLI
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php \
    && mv composer.phar /usr/local/bin/composer

# Setup Volta environment
SHELL ["/bin/bash", "-c"]
ENV BASH_ENV=~/.bashrc
ENV VOLTA_HOME=/root/.volta
ENV PATH=$VOLTA_HOME/bin:$PATH

# Install Volta
RUN curl https://get.volta.sh | bash

# Install Memcached PHP extension with correct libmemcached path
RUN pecl list | grep -q memcached || pecl install memcached \
    && cat /usr/local/etc/php/conf.d/memcached.ini | grep -q memcached.so || echo extension=memcached.so >> /usr/local/etc/php/conf.d/memcached.ini

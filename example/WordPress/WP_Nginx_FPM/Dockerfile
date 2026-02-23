ARG APP_IMAGE=wordpress:fpm-alpine
FROM ${APP_IMAGE}

# ═══════════════════════════════════════════════════════════════════════════
# SYSTEM DEPENDENCIES
# ═══════════════════════════════════════════════════════════════════════════
RUN apk add --no-cache \
    # Basic tools
    curl \
    unzip \
    less \
    vim \
    git \
    wget \
    bash \
    # MariaDB client (for debugging)
    mariadb-client \
    # Build dependencies (for PECL extensions)
    $PHPIZE_DEPS \
    # Required for memcached
    libmemcached-dev \
    zlib-dev \
    # Required for zip
    libzip-dev \
    # Linux headers (for some extensions)
    linux-headers \
    # Python (if needed for scripts)
    python3 \
    py3-pip

# ═══════════════════════════════════════════════════════════════════════════
# PHP EXTENSIONS
# ═══════════════════════════════════════════════════════════════════════════

# Install zip extension (if not already installed)
RUN docker-php-ext-install zip || true

# Install Xdebug
RUN pecl list | grep -q xdebug || pecl install xdebug \
    && docker-php-ext-enable xdebug

# Install Memcached
RUN pecl list | grep -q memcached || pecl install memcached \
    && docker-php-ext-enable memcached

# Enable Opcache (already included in base image)
RUN docker-php-ext-enable opcache

# ═══════════════════════════════════════════════════════════════════════════
# WP-CLI
# ═══════════════════════════════════════════════════════════════════════════
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp

# ═══════════════════════════════════════════════════════════════════════════
# COMPOSER
# ═══════════════════════════════════════════════════════════════════════════
RUN curl -sS https://getcomposer.org/installer | php \
    && mv composer.phar /usr/local/bin/composer

# ═══════════════════════════════════════════════════════════════════════════
# VOLTA (Node.js version manager) - can't work inside Alpine and all musl libc based distros
# ═══════════════════════════════════════════════════════════════════════════
# ENV BASH_ENV=/root/.bashrc
# ENV VOLTA_HOME=/root/.volta
# ENV PATH=$VOLTA_HOME/bin:$PATH

# RUN curl https://get.volta.sh | bash

# ═══════════════════════════════════════════════════════════════════════════
# SMTP
# ═══════════════════════════════════════════════════════════════════════════
RUN apk add --no-cache msmtp && \
    ln -sf /usr/bin/msmtp /usr/sbin/sendmail

# ═══════════════════════════════════════════════════════════════════════════
# CLEANUP
# ═══════════════════════════════════════════════════════════════════════════
RUN rm -rf /var/cache/apk/* /tmp/*

# Set working directory
WORKDIR /var/www/html

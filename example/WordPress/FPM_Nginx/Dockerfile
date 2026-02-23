ARG APP_IMAGE=php:8.4.18-fpm-trixie

FROM ${APP_IMAGE}

# ═══════════════════════════════════════════════════════════════════════════
# SYSTEM DEPENDENCIES
# ═══════════════════════════════════════════════════════════════════════════
RUN apt-get update && apt-get install -y --no-install-recommends \
    # Basic tools
    curl \
    unzip \
    less \
    vim \
    git \
    wget \
    bash \
    mariadb-client \
    msmtp \
    python3 \
    python3-pip \
    \
    # PHP build deps
    $PHPIZE_DEPS \
    \
    # Required for PHP extensions
    libzip-dev \
    zlib1g-dev \
    libpng-dev \
    libjpeg62-turbo-dev \
    libfreetype6-dev \
    libwebp-dev \
    libavif-dev \
    libonig-dev \
    libxml2-dev \
    libicu-dev \
    libxslt1-dev \
    libmemcached-dev \
    libsodium-dev \
    \
    # ImageMagick build-time delegate libraries
    libgomp1 \
    libjpeg-dev \
    libpng-dev \
    libwebp-dev \
    libheif-dev \
    libde265-dev \
    librsvg2-dev \
    libxml2-dev \
    libfreetype6-dev \
    ghostscript \
    libgs-dev \
    libfftw3-dev \
    liblcms2-dev \
    libtiff-dev \
    libopenjp2-7-dev \
    \
    && rm -rf /var/lib/apt/lists/*

# ═══════════════════════════════════════════════════════════════════════════
# BUILD IMAGEMAGICK FROM SOURCE (always latest release)
# ═══════════════════════════════════════════════════════════════════════════
RUN IMAGEMAGICK_VERSION=$(curl -s https://api.github.com/repos/ImageMagick/ImageMagick/releases/latest \
    | grep '"tag_name"' | cut -d'"' -f4) \
    && echo "Building ImageMagick ${IMAGEMAGICK_VERSION}" \
    && curl -fsSL https://github.com/ImageMagick/ImageMagick/archive/refs/tags/${IMAGEMAGICK_VERSION}.tar.gz \
    | tar -xz -C /tmp \
    && cd /tmp/ImageMagick-${IMAGEMAGICK_VERSION} \
    && ./configure \
    --prefix=/usr/local \
    --with-magick-plus-plus=no \
    --with-jpeg=yes \
    --with-png=yes \
    --with-webp=yes \
    --with-heic=yes \
    --with-rsvg=yes \
    --with-tiff=yes \
    --with-openjp2=yes \
    --with-freetype=yes \
    --with-gslib=yes \
    --with-gs-font-dir=/usr/share/fonts/type1/gsfonts \
    --with-lcms=yes \
    --with-xml=yes \
    --with-fftw=yes \
    --enable-hdri=yes \
    --enable-shared \
    --disable-static \
    && make -j$(nproc) \
    && make install \
    && ldconfig \
    && rm -rf /tmp/ImageMagick-${IMAGEMAGICK_VERSION}

# Install imagick PECL extension against the freshly built ImageMagick
RUN pecl install imagick \
    && docker-php-ext-enable imagick \
    && echo "extension=imagick.so" > /usr/local/etc/php/conf.d/docker-php-ext-imagick.ini

# Link msmtp as sendmail
RUN ln -sf /usr/bin/msmtp /usr/sbin/sendmail

# ═══════════════════════════════════════════════════════════════════════════
# CORE WORDPRESS PHP EXTENSIONS
# ═══════════════════════════════════════════════════════════════════════════

# Configure GD with full format support (JPEG + FreeType + WebP + AVIF)
RUN docker-php-ext-configure gd \
    --with-freetype \
    --with-jpeg \
    --with-webp \
    --with-avif

RUN docker-php-ext-install -j$(nproc) \
    mysqli \
    pdo \
    pdo_mysql \
    mbstring \
    exif \
    pcntl \
    bcmath \
    intl \
    zip \
    gd \
    soap \
    xsl \
    opcache

# ═══════════════════════════════════════════════════════════════════════════
# PECL EXTENSIONS
# ═══════════════════════════════════════════════════════════════════════════

# Install Redis
RUN pecl install redis \
    && docker-php-ext-enable redis

# Install Memcached
RUN pecl install memcached \
    && docker-php-ext-enable memcached

# Unlock PDF, EPS, PS and XPS processing in ImageMagick policy
# (Ghostscript must be installed for this to work)
RUN find /etc /usr/local/etc -name "policy.xml" 2>/dev/null | xargs -I{} sed -i \
    -e 's/<policy domain="coder" rights="none" pattern="PDF"/<policy domain="coder" rights="read|write" pattern="PDF"/' \
    -e 's/<policy domain="coder" rights="none" pattern="EPS"/<policy domain="coder" rights="read|write" pattern="EPS"/' \
    -e 's/<policy domain="coder" rights="none" pattern="PS"/<policy domain="coder" rights="read|write" pattern="PS"/' \
    -e 's/<policy domain="coder" rights="none" pattern="XPS"/<policy domain="coder" rights="read|write" pattern="XPS"/' \
    {}

# Install Xdebug (comment out or remove in production)
RUN pecl install xdebug \
    && docker-php-ext-enable xdebug

# ═══════════════════════════════════════════════════════════════════════════
# WP-CLI
# ═══════════════════════════════════════════════════════════════════════════
RUN curl -o /usr/local/bin/wp https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x /usr/local/bin/wp

# ═══════════════════════════════════════════════════════════════════════════
# COMPOSER
# ═══════════════════════════════════════════════════════════════════════════
RUN curl -sS https://getcomposer.org/installer | php \
    && mv composer.phar /usr/local/bin/composer

# ═══════════════════════════════════════════════════════════════════════════
# CLEANUP BUILD DEPENDENCIES
# NOTE: Must happen AFTER all pecl/phpize-based extensions are installed
# ═══════════════════════════════════════════════════════════════════════════
RUN apt-get purge -y $PHPIZE_DEPS \
    && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# ═══════════════════════════════════════════════════════════════════════════
# WORDPRESS INSTALL (BUILD TIME) — uncomment to bake WP into the image
# ═══════════════════════════════════════════════════════════════════════════
# WORKDIR /var/www

# RUN curl -o wordpress.tar.gz https://wordpress.org/latest.tar.gz \
#     && tar -xzf wordpress.tar.gz \
#     && rm wordpress.tar.gz \
#     && mkdir -p /var/www/html \
#     && cp -a wordpress/. /var/www/html/ \
#     && rm -rf wordpress \
#     && chown -R www-data:www-data /var/www/html

WORKDIR /var/www/html

FROM php:8.2-fpm-alpine

# Install system dependencies
RUN apk add --no-cache \
    postgresql-client \
    postgresql-dev \
    wget \
    git \
    curl \
    zip \
    unzip \
    libpng-dev \
    libjpeg-turbo-dev \
    freetype-dev \
    gmp-dev \
    icu-dev \
    zlib-dev \
    libzip-dev \
    imagemagick \
    imagemagick-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) \
    gd \
    pdo_pgsql \
    pgsql \
    gmp \
    intl \
    zip \
    opcache \
    && pecl install imagick \
    && docker-php-ext-enable imagick

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Set working directory
WORKDIR /opt/drupal

# Create necessary directories
RUN mkdir -p web/profiles web/themes web/modules/custom && \
    chown -R www-data:www-data /opt/drupal

# Copy PHP configuration
COPY docker/php/php.ini /usr/local/etc/php/php.ini
COPY docker/php/php-fpm.conf /usr/local/etc/php-fpm.d/www.conf

# Download and install Drupal with farmOS
RUN composer create-project farmos/farm /opt/drupal --prefer-dist --no-dev

# Set proper permissions
RUN chown -R www-data:www-data /opt/drupal && \
    find /opt/drupal -type d -exec chmod 755 {} \; && \
    find /opt/drupal -type f -exec chmod 644 {} \;

EXPOSE 9000

CMD ["php-fpm"]

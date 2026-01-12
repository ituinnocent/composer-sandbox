# Dockerfile
FROM wordpress:php8.2-fpm

# Build arguments for optional features
ARG INSTALL_XDEBUG=false
ARG INSTALL_NODE=false

# Set environment variables
ENV COMPOSER_ALLOW_SUPERUSER=1 \
    COMPOSER_HOME=/tmp/composer

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    zip \
    unzip \
    libzip-dev \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libonig-dev \
    libicu-dev \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js if requested
RUN if [ "$INSTALL_NODE" = "true" ]; then \
    curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
    && apt-get install -y nodejs; \
fi

# Install PHP extensions
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) \
    mysqli \
    pdo \
    pdo_mysql \
    pdo_pgsql \
    gd \
    zip \
    intl \
    mbstring \
    exif \
    opcache \
    bcmath

# Install XDebug if requested
RUN if [ "$INSTALL_XDEBUG" = "true" ]; then \
    pecl install xdebug \
    && docker-php-ext-enable xdebug; \
fi

# Install Redis extension (optional but useful)
RUN pecl install redis && docker-php-ext-enable redis || echo "Redis extension skipped"

# Install Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Install WP-CLI
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp

# Create directory structure matching docker-compose
WORKDIR /var/www/html

# Create uploads directory with correct permissions
RUN mkdir -p /var/www/html/wp-content/uploads \
    && chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html/wp-content

# Copy entrypoint script
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# Switch to non-root user
USER www-data

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD php -f /var/www/html/index.php || exit 1

# Use custom entrypoint
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["php-fpm"]

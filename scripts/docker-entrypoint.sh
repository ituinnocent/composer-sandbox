#!/bin/sh
# docker-entrypoint.sh
set -e

echo "🚀 WordPress Docker Entrypoint"

# Wait for MySQL
if [ -n "$WORDPRESS_DB_HOST" ]; then
    echo "⏳ Waiting for database..."
    while ! mysqladmin ping -h"$WORDPRESS_DB_HOST" --silent; do
        sleep 2
    done
    echo "✅ Database ready"
fi

# Set WordPress URLs if not set
if [ -n "$WP_HOME" ]; then
    echo "🌐 Setting WordPress URLs: $WP_HOME"
    wp option update home "$WP_HOME" --allow-root 2>/dev/null || true
    wp option update siteurl "$WP_HOME" --allow-root 2>/dev/null || true
fi

# Fix permissions
chown -R www-data:www-data /var/www/html/web/wp-content
chmod -R 755 /var/www/html/web/wp-content/uploads

echo "✅ Entrypoint complete"
exec "$@"

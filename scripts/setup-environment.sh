#!/bin/bash
# scripts/setup-environment.sh
# This script runs the PHP Setup class

echo "🚀 Running environment setup..."

# Check if vendor/autoload.php exists
if [ ! -f "vendor/autoload.php" ]; then
    echo "❌ Composer dependencies not installed. Running composer install..."
    composer install --no-interaction --prefer-dist
fi

# Run the PHP Setup class
php -r "
require 'vendor/autoload.php';
MyProject\Setup::setupEnvironment();
"

# Check exit status
if [ $? -eq 0 ]; then
    echo "✅ Environment setup completed successfully!"
else
    echo "❌ Environment setup failed!"
    exit 1
fi

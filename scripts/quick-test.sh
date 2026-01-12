#!/bin/bash
# scripts/quick-test.sh
echo "🚀 Quick Test Mode"

echo "1. Testing config files..."
ERRORS=0

# Test each config file
for file in config/nginx/nginx.conf config/php/php.ini config/mysql/my.cnf; do
    if [ -f "$file" ]; then
        echo "   ✅ $file exists"
    else
        echo "   ❌ $file missing"
        ((ERRORS++))
    fi
done

echo ""
echo "2. Testing Docker files..."
for file in docker-compose.yml Dockerfile docker-entrypoint.sh; do
    if [ -f "$file" ]; then
        echo "   ✅ $file exists"
    else
        echo "   ❌ $file missing"
        ((ERRORS++))
    fi
done

echo ""
echo "3. Testing .env..."
if [ -f ".env" ]; then
    echo "   ✅ .env exists"
    # Check critical variables
    for var in APP_NAME WP_DOMAINS DB_NAME; do
        if grep -q "^$var=" .env; then
            echo "     ✅ $var is set"
        else
            echo "     ⚠️  $var not found in .env"
        fi
    done
else
    echo "   ❌ .env missing"
    ((ERRORS++))
fi

echo ""
echo "4. Testing PHP Setup..."
if php -r "require 'vendor/autoload.php'; echo '✅ Autoload works';" 2>/dev/null; then
    echo "   ✅ PHP autoload works"
else
    echo "   ❌ PHP autoload failed"
    ((ERRORS++))
fi

echo ""
echo "5. Testing Docker Compose..."
if docker-compose config > /dev/null 2>&1; then
    echo "   ✅ docker-compose.yml is valid"
else
    echo "   ❌ docker-compose.yml has errors"
    ((ERRORS++))
fi

echo ""
echo "========================================"
if [ $ERRORS -eq 0 ]; then
    echo "🎉 All tests passed! Your setup looks good."
    echo ""
    echo "To start:"
    echo "1. Run: ./scripts/init.sh"
    echo "2. Run: sudo php scripts/setup-hosts.php"
    echo "3. Run: docker-compose up -d --build"
else
    echo "⚠️  Found $ERRORS issue(s) that need fixing."
    exit 1
fi

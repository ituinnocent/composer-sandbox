#!/bin/bash

# scripts/test-ssl-bash.sh
echo "🔧 Testing SSL Generation (Bash Version)"

# Clean SSL directory
echo "1. Cleaning SSL directory..."
rm -rf ssl
mkdir -p ssl

# Run PHP setup
echo "2. Running PHP Setup..."
php -r "
error_reporting(E_ALL);
ini_set('display_errors', 1);
require 'vendor/autoload.php';
echo '   Calling Setup::setupEnvironment()...\n';
try {
    MyProject\Setup::setupEnvironment();
    echo '   ✅ Setup completed\n';
} catch (Exception \$e) {
    echo '   ❌ Error: ' . \$e->getMessage() . '\n';
    echo '   OpenSSL errors: ' . openssl_error_string() . '\n';
}
"

# Check results
echo ""
echo "3. Checking results..."
if [ -f "ssl/my-website.local.crt" ]; then
    echo "   ✅ SSL certificate exists"
    echo "   Size: $(stat -c%s ssl/my-website.local.crt) bytes"

    # Check if it's a valid certificate
    if openssl x509 -in ssl/my-website.local.crt -text -noout 2>/dev/null; then
        echo "   ✅ Certificate is valid"
    else
        echo "   ⚠️  Certificate file exists but is invalid"
    fi
else
    echo "   ❌ SSL certificate not created"

    # Try manual creation
    echo ""
    echo "4. Trying manual SSL creation..."
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout ssl/my-website.local.key \
        -out ssl/my-website.local.crt \
        -subj "/C=US/ST=State/L=City/O=Org/CN=my-website.local" 2>&1

    if [ $? -eq 0 ]; then
        echo "   ✅ Manual SSL creation successful"
        chmod 600 ssl/my-website.local.key
    else
        echo "   ❌ Manual SSL creation also failed"
        echo "   Check if openssl is installed:"
        which openssl
        openssl version
    fi
fi

echo ""
echo "=== FINAL CHECK ==="
ls -la ssl/ 2>/dev/null || echo "SSL directory empty or missing"

#!/bin/zsh

echo "🔧 Debugging SSL Generation"

echo "1. Cleaning up..."

rm -rf ssl 2>/dev/null

echo "\n2. Testing PHP..."
php -v

echo "\n3. Running Setup.php..."
php -r '
require "vendor/autoload.php";
echo "Starting setup...\n";
MyProject\Setup::setupEnvironment();
echo "Setup finished\n";
'

echo "\n4. Checking results..."
if [[ -f "ssl/my-website.local.crt" ]]; then
    echo "✅ SSL certificate created"
    echo "Size: $(stat -f%z ssl/my-website.local.crt 2>/dev/null || stat -c%s ssl/my-website.local.crt 2>/dev/null) bytes"
else
    echo "❌ SSL certificate NOT created"

    # Check if directory exists
    if [[ -d "ssl" ]]; then
        echo "SSL directory exists but is empty"
        ls -la ssl/
    else
        echo "SSL directory doesn't exist"
    fi
fi

echo "\n5. Manual SSL creation..."
mkdir -p ssl
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout ssl/test.local.key \
    -out ssl/test.local.crt \
    -subj "/C=US/ST=State/L=City/O=Org/CN=test.local" 2>&1

if [[ $? -eq 0 ]]; then
    echo "✅ Manual SSL creation complete"
    rm ssl/test.*
else
    echo "❌ Manual SSL creation failed"
fi

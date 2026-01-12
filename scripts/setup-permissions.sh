#!/bin/bash
# scripts/setup-permissions.sh
echo "🔧 Setting up permissions..."

# Scripts
echo "Setting script permissions..."
find scripts/ -name "*.sh" -type f -exec chmod +x {} \;

# PHP scripts - make executable if they have shebang (#!/usr/bin/env php)
for php_script in scripts/*.php; do
    if [ -f "$php_script" ]; then
        # Check if it has PHP shebang
        if head -1 "$php_script" | grep -q "^#!/usr/bin/env php"; then
            chmod +x "$php_script"
            echo "✓ Made executable: $php_script"
        else
            chmod 644 "$php_script"
            echo "✓ Set readable: $php_script"
        fi
    fi
done

# Config files
echo "Setting config file permissions..."
find config/ -type f -name "*.conf" -o -name "*.ini" -o -name "*.cnf" | xargs chmod 644

# SSL directory
if [ -d "ssl" ]; then
    echo "Setting SSL permissions..."
    chmod 600 ssl/*.key 2>/dev/null || true
    chmod 644 ssl/*.crt 2>/dev/null || true
fi

# Make sure docker-entrypoint.sh is executable
if [ -f "docker-entrypoint.sh" ]; then
    chmod +x docker-entrypoint.sh
    echo "✓ Made executable: docker-entrypoint.sh"
fi

echo "✅ Permissions set!"

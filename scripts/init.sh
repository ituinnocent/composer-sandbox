#!/bin/bash
# scripts/init.sh
echo "🚀 Initializing WordPress Docker Setup..."

# Run the setup-environment script
./scripts/setup-environment.sh

# Generate Nginx config
echo "🌐 Generating Nginx configuration..."
php scripts/generate-nginx-config.php

echo "✅ Initialization complete!"
echo ""
echo "Next steps:"
echo "1. Update /etc/hosts (run with sudo):"
echo "   sudo php scripts/setup-hosts.php"
echo ""
echo "2. Start Docker:"
echo "   docker-compose up -d --build"
echo ""
echo "3. Access your site:"
echo "   https://my-website.local"

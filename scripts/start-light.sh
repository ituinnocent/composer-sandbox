#!/bin/bash
# scripts/start-light.sh
echo "🚀 Starting lightweight WordPress..."

# Kill existing containers to free resources
docker-compose down 2>/dev/null

# Clean Docker cache (optional)
docker system prune -f --volumes 2>/dev/null

# Start only essential services
docker-compose -f docker-compose.light.yml up -d \
  --scale phpmyadmin=0 \  # Don't start phpmyadmin by default
  wordpress mysql

echo ""
echo "✅ Lightweight stack running!"
echo "📊 Resource usage:"
echo "   WordPress: 128-256MB RAM"
echo "   MySQL:     128-256MB RAM"
echo "   Total:     ~400MB RAM"
echo ""
echo "🌐 Access: http://localhost"
echo ""
echo "To start phpMyAdmin when needed:"
echo "  docker-compose -f docker-compose.light.yml up -d phpmyadmin"

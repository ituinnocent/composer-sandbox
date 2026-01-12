#!/bin/bash
# setup-light.sh - Complete lightweight setup

echo "🪶 Setting up ultra-light WordPress..."

# 1. Use minimal .env
cp .env.light.example .env

# 2. Build lightweight image
docker build -f Dockerfile.alpine -t wordpress-light .

# 3. Start minimal stack
docker-compose -f docker-compose.light.yml up -d

# 4. Install WordPress with optimizations
docker-compose -f docker-compose.light.yml exec wordpress wp core install \
  --url=http://localhost \
  --title="Lightweight Site" \
  --admin_user=admin \
  --admin_password=password \
  --admin_email=admin@localhost \
  --skip-email

# 5. Enable optimizations
docker-compose -f docker-compose.light.yml exec wordpress \
  wp plugin install query-monitor --activate

echo ""
echo "✅ Ultra-light WordPress ready!"
echo "📊 Expected resource usage:"
echo "   - RAM: ~400MB"
echo "   - CPU: <10% idle"
echo "   - Disk: <1GB"
echo ""
echo "🌐 Access: http://localhost"
echo "👤 Admin: http://localhost/wp-admin"

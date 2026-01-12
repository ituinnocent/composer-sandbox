#!/bin/bash
# test-setup.sh
echo "🧪 Testing Docker WordPress Setup..."

# Test 1: Docker Compose config
echo "1. Checking docker-compose config..."
docker-compose config > /dev/null && echo "✅ docker-compose.yml valid" || echo "❌ docker-compose.yml error"

# Test 2: Build images
echo "2. Building Docker images..."
docker-compose build --quiet && echo "✅ Images built successfully" || echo "❌ Build failed"

# Test 3: Start containers
echo "3. Starting containers..."
docker-compose up -d && echo "✅ Containers started" || echo "❌ Failed to start"

# Test 4: Check services
echo "4. Checking services..."
sleep 5
docker-compose ps | grep -q "Up" && echo "✅ All services running" || echo "❌ Some services down"

# Test 5: WordPress health
echo "5. Testing WordPress..."
curl -s -o /dev/null -w "%{http_code}" http://localhost | grep -q "200\|302" && echo "✅ WordPress responding" || echo "❌ WordPress not responding"

echo ""
echo "📊 Summary:"
docker-compose ps
echo ""
echo "🌐 Access: http://localhost"
echo "🐘 PHPMyAdmin: http://localhost:8080"

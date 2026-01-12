#!/bin/bash php
echo "🧪 Testing Docker WordPress Setup..."

echo "1. Checking docker-compose config..."
docker-compose config > /dev/null && echo "✅ docker-compose.yml valid" || echo "❌ docker-compose.yml error"

echo "2. Building Docker images..."
docker-compose build --quiet && echo "✅ Images built successfully" || echo "❌ Build failed"

echo "3. Starting containers..."
docker-compose up -d && echo "✅ Containers started" || echo "❌ Failed to start"

echo "4. Checking services..."
sleep 5
docker-compose ps | grep -q "Up" && echo "✅ All services running" || echo "❌ Some services down"

echo "5. Testing WordPress health..."
curl -s -o /dev/null -w "%{http_code}" http://localhost | grep -q "200\|302" && echo "✅ WordPress responding" || echo "❌ WordPress not responding"

echo ""
echo "📊 Summary:"
docker-compose ps
echo ""
echo "🌐 Access: http://localhost"
echo "🐘 PHPMyAdmin: http://localhost:8080"

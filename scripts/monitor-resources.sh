#!/bin/bash
# scripts/monitor-resources.sh

echo "📊 Docker Resource Monitor"
echo "=========================="

# Show container resource usage
docker stats --no-stream --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.MemPerc}}"

echo ""
echo "💾 Disk Usage:"
docker system df

echo ""
echo "🐳 Running Containers:"
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

echo ""
echo "🔧 Recommendations:"
TOTAL_MEM=$(docker stats --no-stream --format "{{.MemUsage}}" | cut -d'/' -f1 | tr -d 'MiB' | awk '{sum+=$1} END {print sum}')
if [ "$TOTAL_MEM" -gt 1000 ]; then
  echo "❌ High memory usage (${TOTAL_MEM}MB). Consider:"
  echo "   - Run: ./scripts/start-light.sh"
  echo "   - Disable unused containers"
elif [ "$TOTAL_MEM" -lt 500 ]; then
  echo "✅ Good memory usage (${TOTAL_MEM}MB)"
fi

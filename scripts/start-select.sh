#!/bin/bash
# scripts/start-select.sh

SERVICES=""

case "$1" in
  "minimal")
    SERVICES="wordpress mysql"
    CONFIG="docker-compose.light.yml"
    ;;
  "dev")
    SERVICES="wordpress mysql phpmyadmin"
    CONFIG="docker-compose.yml"
    ;;
  "full")
    SERVICES="wordpress mysql phpmyadmin mailhog redis"
    CONFIG="docker-compose.yml"
    ;;
  *)
    echo "Usage: $0 {minimal|dev|full}"
    exit 1
    ;;
esac

echo "Starting $1 mode with: $SERVICES"
docker-compose -f $CONFIG up -d $SERVICES

# Show resource usage
docker stats --no-stream $(docker-compose -f $CONFIG ps -q)

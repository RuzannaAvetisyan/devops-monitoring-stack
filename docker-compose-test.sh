#!/bin/bash

# docker-compose-test.sh - Testing script for monitoring stack
echo "==========================================
Docker Compose Monitoring Stack Test
=========================================="

# Test 1: Check Docker
echo "Test 1: Checking Docker installation..."
if ! command -v docker >/dev/null 2>&1; then
    echo "ERROR: Docker is not installed"
    exit 1
fi
echo "OK: Docker is installed"

# Test 2: Check Docker Compose
echo "Test 2: Checking Docker Compose installation..."
if ! docker compose version >/dev/null 2>&1; then
    echo "ERROR: Docker Compose is not installed"
    exit 1
fi
echo "OK: Docker Compose is installed"

# Test 3: Validate docker-compose.yml
echo "Test 3: Validating docker-compose.yml..."
if ! docker compose config >/dev/null 2>&1; then
    echo "ERROR: docker-compose.yml validation failed"
    docker compose config
    exit 1
fi
echo "OK: docker-compose.yml is valid"

# Test 4: Start services
echo "Test 4: Starting services..."
if ! docker compose up -d; then
    echo "ERROR: Failed to start services"
    exit 1
fi
echo "OK: Services started"

# Test 5: Check containers
echo "Test 5: Checking container status..."
TIMEOUT=180  # 3 minutes recommended timeout
WAIT_TIME=0
CHECK_INTERVAL=5
CONTAINERS=("prometheus" "grafana" "node-exporter")
while [ $WAIT_TIME -lt $TIMEOUT ]; do
    ALL_RUNNING=true
    for container in "${CONTAINERS[@]}"; do
        if [ "$(docker inspect -f '{{.State.Running}}' $container 2>/dev/null)" != "true" ]; then
            ALL_RUNNING=false
            break
        fi
    done
    if [ "$ALL_RUNNING" = true ]; then
        echo "OK: All containers are running"
        docker compose ps
        break
    fi

    sleep $CHECK_INTERVAL
    WAIT_TIME=$((WAIT_TIME + CHECK_INTERVAL))
done

if [ $WAIT_TIME -ge $TIMEOUT ]; then
    echo "ERROR: Timeout waiting for containers to start"
    docker compose ps
    docker compose logs
    exit 1
fi

# Test 6: Check endpoints
echo "Test 6: Testing service endpoints..."

# Function to check endpoint with retries
check_endpoint() {
    local url=$1
    local service=$2
    local max_attempts=5
    local attempt=1
    local retry_interval=2

    while [ $attempt -le $max_attempts ]; do
        if curl -f $url >/dev/null 2>&1; then
            echo "OK: $service is accessible"
            return 0
        fi
        sleep $retry_interval
        attempt=$((attempt + 1))
    done

    echo "ERROR: $service endpoint check failed after $max_attempts attempts"
    return 1
}

# Check each endpoint
if ! check_endpoint "http://localhost:9090" "Prometheus on port 9090"; then
    exit 1
fi

if ! check_endpoint "http://localhost:3000" "Grafana on port 3000"; then
    exit 1
fi

if ! check_endpoint "http://localhost:9100/metrics" "Node Exporter on port 9100"; then
    exit 1
fi

# Summary
echo "==========================================
All tests completed successfully!
==========================================
Services are running:
- Prometheus:    http://localhost:9090
- Grafana:       http://localhost:3000
- Node Exporter: http://localhost:9100/metrics
"

# Cleanup
echo "==========================================
Cleanup
==========================================
Stopping services..."

if docker compose down; then
    echo "OK: Services stopped successfully"
else
    echo "ERROR: Failed to stop services"
    exit 1
fi

# Additional cleanup check - verify no containers exist
if [ -n "$(docker compose ps -q)" ]; then
    echo "WARNING: Some containers still exist"
    docker compose ps
    echo "Forcing cleanup..."
    docker compose down -v --rmi all --remove-orphans
fi

echo "Cleanup completed"
exit 0

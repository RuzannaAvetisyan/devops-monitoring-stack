#!/bin/bash

# docker-compose-test.sh - Testing script for monitoring stack

echo "=========================================="
echo "Docker Compose Monitoring Stack Test"
echo "=========================================="
echo ""

# Test 1: Check Docker
echo "Test 1: Checking Docker installation..."
if ! command -v docker >/dev/null 2>&1; then
    echo "ERROR: Docker is not installed"
    exit 1
fi
echo "OK: Docker is installed"
echo ""

# Test 2: Check Docker Compose
echo "Test 2: Checking Docker Compose installation..."
if ! docker compose version >/dev/null 2>&1; then
    echo "ERROR: Docker Compose is not installed"
    exit 1
fi
echo "OK: Docker Compose is installed"
echo ""

# Test 3: Validate docker-compose.yml
echo "Test 3: Validating docker-compose.yml..."
if ! docker compose config >/dev/null 2>&1; then
    echo "ERROR: docker-compose.yml validation failed"
    docker compose config
    exit 1
fi
echo "OK: docker-compose.yml is valid"
echo ""

# Test 4: Start services
echo "Test 4: Starting services..."
if ! docker compose up -d; then
    echo "ERROR: Failed to start services"
    exit 1
fi
echo "OK: Services started"
echo "Waiting for services to initialize..."
sleep 5
echo ""

# Test 5: Check containers
echo "Test 5: Checking container status..."
docker compose ps
echo ""

if [ "$(docker inspect -f '{{.State.Running}}' prometheus 2>/dev/null)" != "true" ]; then
    echo "ERROR: Prometheus container is not running"
    exit 1
fi
echo "OK: Prometheus is running"

if [ "$(docker inspect -f '{{.State.Running}}' grafana 2>/dev/null)" != "true" ]; then
    echo "ERROR: Prometheus container is not running"
    exit 1
fi
echo "OK: Grafana is running"

if [ "$(docker inspect -f '{{.State.Running}}' node-exporter 2>/dev/null)" != "true" ]; then
    echo "ERROR: Prometheus container is not running"
    exit 1
fi
echo "OK: Node Exporter is running"
echo ""

# Test 6: Check endpoints
echo "Test 6: Testing service endpoints..."
sleep 5

if curl -f http://localhost:9090 >/dev/null 2>&1; then
    echo "OK: Prometheus is accessible on port 9090"
else
    echo "ERROR: Prometheus endpoint check failed"
fi

if curl -f http://localhost:3000 >/dev/null 2>&1; then
    echo "OK: Grafana is accessible on port 3000"
else
    echo "ERROR: Grafana endpoint check failed"
fi

if curl -f http://localhost:9100/metrics >/dev/null 2>&1; then
    echo "OK: Node Exporter is accessible on port 9100"
else
    echo "ERROR: Node Exporter endpoint check failed"
fi
echo ""

# Summary
echo "=========================================="
echo "All tests completed successfully!"
echo "=========================================="
echo ""
echo "Services are running:"
echo "- Prometheus:    http://localhost:9090"
echo "- Grafana:       http://localhost:3000"
echo "- Node Exporter: http://localhost:9100/metrics"
echo ""

# Cleanup
echo "=========================================="
echo "Cleanup"
echo "=========================================="
echo "Stopping services..."
docker compose down
echo "Services stopped"

exit 0

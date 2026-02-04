# DevOps Monitoring Stack

Complete monitoring solution with Prometheus, Grafana, and Node Exporter.

## Quick Start

```bash
# Clone and start
git clone https://github.com/RuzannaAvetisyan/devops-monitoring-stack.git
cd devops-monitoring-stack
docker compose up -d

# Wait 30 seconds, then access:
# Grafana: http://localhost:3000 (admin/admin)
# Prometheus: http://localhost:9090
```

## What's Included

- **Grafana** (port 3000) - Dashboards and visualization
- **Prometheus** (port 9090) - Metrics storage and querying
- **Node Exporter** (port 9100) - System metrics collection


## 🛠 Common Commands

```bash
# Start services
docker compose up -d

# Stop services
docker compose down

# View logs
docker compose logs -f

# Restart services
docker compose restart
```

## 📊 Pre-built Dashboards

**Grafana** includes:
- **Node Exporter Full** - Complete system monitoring (CPU, Memory, Disk, Network)

Navigate to: **Dashboards** → **Browse** → **Node Exporter Monitoring**

## Troubleshooting

```bash
# Services won't start?
docker compose logs

# Port already in use?
lsof -i :3000
lsof -i :9090

# Grafana shows "No data"?
curl http://localhost:9090/-/healthy
# Check: http://localhost:9090/targets
```

## Project Structure

```
devops-monitoring-stack/
├── .github/workflows/       # GitHub Actions
├── grafana/                 # Grafana config & dashboards
├── prometheus/              # Prometheus config
└── docker-compose.yml       # Services definition
```

## Useful PromQL Queries

```promql
# CPU usage %
100 - (avg by (instance) (irate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)

# Memory usage %
100 * (1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes))

# Disk usage %
100 - ((node_filesystem_avail_bytes / node_filesystem_size_bytes) * 100)
```
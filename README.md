# DevOps Monitoring Stack

Complete monitoring solution with Prometheus, Grafana, Node Exporter and automated GitHub Actions deployment.

## Quick Start

```bash
git clone https://github.com/RuzannaAvetisyan/devops-monitoring-stack.git
cd devops-monitoring-stack
docker compose up -d
```

Access dashboards:
- **Grafana**: http://localhost:3000 (admin/admin)
- **Prometheus**: http://localhost:9090

## What's Included

- **Grafana** (port 3000) - Dashboards and visualization
- **Prometheus** (port 9090) - Metrics storage and querying
- **Node Exporter** (port 9100) - System metrics collection

## GitHub Actions Deployment

### Setup Runner (one-time)

Follow [GitHub's official guide](https://docs.github.com/en/actions/hosting-your-own-runners/managing-self-hosted-runners/adding-self-hosted-runners) or:

```
GitHub → Settings → Actions → Runners → New self-hosted runner
```

### Deploy

1. Start runner in terminal
2. GitHub → Actions → **Deploy** → Run workflow
3. Access: http://localhost:3000

### Stop

1. Services: GitHub → Actions → **Stop** → Run workflow
2. Stop runner in terminal

### ⚠️ Security Warning

**This demo uses a self-hosted runner with a public repository - NOT recommended for production.**

Self-hosted runners on public repos are unsafe because anyone can fork your repo and execute malicious code on your machine via pull requests.

**For production:**
- Use private repositories, OR
- Use GitHub-hosted runners

**Demo safety:**
- Keep runner offline when not demonstrating
- Only run workflows you've reviewed

[More info](https://docs.github.com/en/actions/security-guides/security-hardening-for-github-actions#hardening-for-self-hosted-runners)

## Monitoring Dashboard

**Node Exporter Monitoring** dashboard includes:
- CPU Usage (%)
- Memory Usage (%)
- Disk Usage by Mountpoint (%)
- Network Traffic (RX/TX)

Navigate: **Dashboards** → **Node Exporter Monitoring**

## Metrics

### CPU
```promql
100 - (avg by(instance) (rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)
```

### Memory
```promql
(1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)) * 100
```

### Disk
```promql
(1 - (node_filesystem_avail_bytes{device!~"tmpfs|loop.*",fstype!~"tmpfs|overlay"} / 
      node_filesystem_size_bytes{device!~"tmpfs|loop.*",fstype!~"tmpfs|overlay"})) * 100
```

### Network
```promql
rate(node_network_receive_bytes_total{device!~"lo|veth.*"}[5m])  # RX
rate(node_network_transmit_bytes_total{device!~"lo|veth.*"}[5m]) # TX
```

## Commands

```bash
docker compose up -d        # Start
docker compose down         # Stop
docker compose logs -f      # View logs
docker compose ps           # Status
```

## Troubleshooting

```bash
# Services won't start?
docker compose logs

# Port already in use?
lsof -i :3000

# Grafana shows "No data"?
curl http://localhost:9090/-/healthy
# Check: http://localhost:9090/targets

# Runner issues
cd ~/actions-runner
./config.sh remove --token OLD_TOKEN
./config.sh --url REPO_URL --token NEW_TOKEN
```

## Project Structure

```
devops-monitoring-stack/
├── .github/workflows/       # CI/CD workflows
├── grafana/                 # Config & dashboards
├── prometheus/              # Config
└── docker-compose.yml       # Services
```

## CI/CD

- **Deploy** - Starts monitoring stack (main branch, manual)
- **Stop** - Stops services (main branch, manual)
- **Test** - Automated tests on every push

---

**Documentation**: [Prometheus](https://prometheus.io/docs/) | [Grafana](https://grafana.com/docs/) | [Node Exporter](https://github.com/prometheus/node_exporter)

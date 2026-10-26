# CMCKO: Centralized Observability Hub (System-3)

Centralized Multi-Cluster Kubernetes Observability Hub running on **System-3 (Windows + WSL)**. 
Scrapes, stores, and visualizes **L4 (Transport)** and **L7 (Application)** metrics from remote spoke clusters:
- **System-1** (macOS + OrbStack): namespace `system-1-cluster` (Load via Apache JMeter)
- **System-2** (Windows + WSL): namespace `system-2-cluster` (Load via Grafana k6)
- **System-3** (This PC / Hub): namespace `hub-namespace` (Central Prometheus + Grafana)

---

## 📁 Clean System-3 File Structure

```
CMCKO/
├── config/
│   ├── prometheus/
│   │   ├── prometheus.yml.template        # Dynamic template with namespaces and IP placeholders
│   │   ├── prometheus.yml                 # Rendered Prometheus scrape configuration
│   │   └── rules/                         # Aggregation and alert rules
│   └── grafana/
│       ├── provisioning/                  # Auto-configured datasources & providers
│       └── dashboards/
│           └── cmcko-multicluster-overview.json # Cyber-observability multi-cluster dashboard
├── data/
│   └── cmcko_logs.db                      # 16 KB SQLite benchmark and incident log
├── scripts/
│   ├── db.py                              # SQLite database manager
│   └── show-test-logs.sh                  # Terminal viewer for L4/L7 test logs
├── docker-compose.yml                     # Prometheus (500MB cap) + Grafana Hub
├── start.sh                               # Interactive hub starter (prompts for IPs)
├── status.sh                              # Live target connection & scrape inspector
├── stop.sh                                # Clean shutdown
└── README.md
```

---

## 🚀 Starting the Hub

Whenever you want to start or reconnect the hub, simply run:

```bash
./start.sh
```

The script will interactively ask you for the current IPs of System-1 and System-2:
```text
➜ Enter IP address for System-1 (macOS OrbStack / JMeter) [192.168.31.9]: 
➜ Enter IP address for System-2 (Windows WSL / k6) [192.168.31.112]: 
```

You can also pass IPs directly without prompting:
```bash
./start.sh 172.27.43.20 172.27.43.30
```

---

## 📊 Viewing the Dashboards

- **Grafana Dashboard**: [http://localhost:3000/d/cmcko-overview](http://localhost:3000/d/cmcko-overview)
  - **Login**: `admin` / `admin`
  - **Filters**: Cluster dropdown (`System-1`, `System-2`, `System-3`) and Namespace dropdown (`system-1-cluster`, `system-2-cluster`).
  - **Sections**:
    1. Executive Cluster Status & KPIs
    2. L4 Network & Transport Telemetry (Throughput, TCP RTT, Packet Rate)
    3. L7 Application RED Metrics (RPS, Latency p50/p95/p99, 4xx/5xx Errors)
    4. Multi-Cluster Benchmark Face-Off (JMeter vs k6)
    5. eBPF Discovered Pods & Microservices
- **Prometheus Targets UI**: [http://localhost:9090/targets](http://localhost:9090/targets)

---

## 🔍 Commands

* **Check connection & targets**:
  ```bash
  ./status.sh
  ```
* **View stored L4/L7 test run logs**:
  ```bash
  bash scripts/show-test-logs.sh
  ```
* **Stop the hub**:
  ```bash
  ./stop.sh
  ```

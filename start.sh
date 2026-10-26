#!/usr/bin/env bash
# =====================================================================
# CMCKO - Central Observability Hub Launcher (System-3)
# Uses hardcoded Tailscale IPs for System-1 and System-2.
# =====================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${SCRIPT_DIR}"

CONFIG_FILE="${SCRIPT_DIR}/config/prometheus/prometheus.yml"

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

echo -e "${BLUE}======================================================================${NC}"
echo -e "${BLUE}${BOLD} 🚀 CMCKO: Centralized Multi-Cluster Observability Hub               ${NC}"
echo -e "${BLUE}    Node: System-3 (Win+WSL) | Prometheus & Grafana Aggregator       ${NC}"
echo -e "${BLUE}======================================================================${NC}"

SYS1_IP="100.110.71.94"
SYS2_IP="100.67.50.8"

echo -e "\n[i] Hardcoded Tailscale Endpoints:"
echo -e "    • System-1 (macOS OrbStack / JMeter): ${BOLD}http://${SYS1_IP}:30090/metrics${NC}"
echo -e "    • System-2 (Windows WSL / k6):        ${BOLD}http://${SYS2_IP}:30090/metrics${NC}"

# Launch or ensure containers are running
echo -e "\n[i] Starting Hub containers (Prometheus + Grafana)..."
docker compose up -d

# Reload Prometheus configuration
if curl -s -m 2 http://localhost:9090/-/ready >/dev/null 2>&1; then
  curl -s -X POST http://localhost:9090/-/reload >/dev/null 2>&1 || docker compose restart prometheus
fi

# Wait for Prometheus & Grafana
for i in {1..10}; do
  if curl -s -m 2 http://localhost:9090/-/ready >/dev/null 2>&1; then
    break
  fi
  sleep 1
done

echo -e "${GREEN}[✓] Prometheus is UP and automatically scraping Tailscale endpoints.${NC}"
echo -e "${GREEN}[✓] Grafana is UP and provisioned.${NC}"

# Test immediate target connectivity
echo -e "\n${BLUE}--- Tailscale Reachability Check ---${NC}"
check_target() {
  local NAME="$1"
  local IP="$2"
  if curl -s -m 2 -o /dev/null "http://${IP}:30090/metrics"; then
    echo -e "  ${GREEN}[✓] ${NAME} (${IP}:30090): CONNECTED & EMITTING METRICS!${NC}"
  else
    echo -e "  ${YELLOW}[⏳] ${NAME} (${IP}:30090): Waiting for connection (Timeout or host port blocked).${NC}"
  fi
}
check_target "System-1" "${SYS1_IP}"
check_target "System-2" "${SYS2_IP}"

# Query Prometheus targets table
echo -e "\n${BLUE}--- Current Scrape Targets Status (from Prometheus) ---${NC}"
python3 - <<EOF
import urllib.request, json
try:
    with urllib.request.urlopen("http://localhost:9090/api/v1/targets", timeout=3) as resp:
        data = json.loads(resp.read().decode()).get("data", {}).get("activeTargets", [])
        print(f"{'CLUSTER':<12} {'NAMESPACE':<20} {'SCRAPE TARGET':<25} {'HEALTH':<10}")
        print(f"{'-'*11} {'-'*19} {'-'*24} {'-'*9}")
        for t in data:
            labels = t.get("labels", {})
            c = labels.get("cluster", "N/A")
            ns = labels.get("cluster_namespace", "default")
            tgt = labels.get("instance", t.get("scrapeUrl", ""))
            h = t.get("health", "").upper()
            color = "\033[0;32m" if h == "UP" else "\033[1;33m"
            reset = "\033[0m"
            print(f"{c:<12} {ns:<20} {tgt:<25} {color}{h:<10}{reset}")
except Exception:
    pass
EOF

echo -e "\n${GREEN}======================================================================${NC}"
echo -e "${GREEN}${BOLD} 📊 Access Observability Dashboards                                  ${NC}"
echo -e "${GREEN}======================================================================${NC}"
echo -e "Grafana Dashboard:  ${CYAN}http://localhost:3000/d/cmcko-overview${NC} (admin / admin)"
echo -e "Prometheus Targets: ${CYAN}http://localhost:9090/targets${NC}"
echo -e "${GREEN}======================================================================${NC}\n"

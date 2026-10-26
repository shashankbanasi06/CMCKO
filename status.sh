#!/usr/bin/env bash
# =====================================================================
# CMCKO - Check Hub Status & Target Scrapes
# =====================================================================
set -uo pipefail

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

echo -e "${BLUE}======================================================================${NC}"
echo -e "${BLUE}${BOLD} CMCKO Hub Status & Scrape Target Diagnostics                        ${NC}"
echo -e "${BLUE}======================================================================${NC}"

# Check Docker containers
echo -e "\nRunning Containers:"
docker ps --filter "name=cmcko-" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

# Check Prometheus Scrape Targets
echo -e "\nTarget Scrapes:"
python3 - <<EOF
import urllib.request, json, sys
try:
    with urllib.request.urlopen("http://localhost:9090/api/v1/targets", timeout=3) as resp:
        data = json.loads(resp.read().decode()).get("data", {}).get("activeTargets", [])
        print(f"{'CLUSTER':<12} {'NAMESPACE':<20} {'SCRAPE TARGET':<25} {'HEALTH':<10} {'LAST DURATION'}")
        print(f"{'-'*11} {'-'*19} {'-'*24} {'-'*9} {'-'*13}")
        for t in data:
            labels = t.get("labels", {})
            c = labels.get("cluster", "N/A")
            ns = labels.get("cluster_namespace", "default")
            tgt = labels.get("instance", t.get("scrapeUrl", ""))
            h = t.get("health", "").upper()
            dur = f"{t.get('lastScrapeDuration', 0):.3f}s"
            color = "\033[0;32m" if h == "UP" else "\033[0;31m"
            reset = "\033[0m"
            print(f"{c:<12} {ns:<20} {tgt:<25} {color}{h:<10}{reset} {dur:<13}")
except Exception as e:
    print(f"Cannot reach Prometheus at http://localhost:9090. Is the hub running?")
    sys.exit(0)
EOF

echo -e "\nGrafana UI: http://localhost:3000/d/cmcko-overview (admin/admin)"
echo -e "Prometheus Targets: http://localhost:9090/targets\n"

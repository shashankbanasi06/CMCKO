#!/usr/bin/env bash
# =====================================================================
# CMCKO - Stop Hub Containers
# =====================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${SCRIPT_DIR}"

echo "Stopping CMCKO Prometheus and Grafana containers..."
docker compose down

echo "✓ CMCKO Hub stopped cleanly."

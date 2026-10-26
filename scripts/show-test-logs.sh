#!/usr/bin/env bash
# =====================================================================
# CMCKO - View Stored Test Logs and Incidents (SQLite)
# =====================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
python3 "${SCRIPT_DIR}/db.py" show

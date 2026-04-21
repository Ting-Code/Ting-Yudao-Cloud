#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
LOG_DIR="${PROJECT_ROOT}/logs/dev-cloud"

mkdir -p "${LOG_DIR}"
touch "${LOG_DIR}/system-server.log" "${LOG_DIR}/infra-server.log" "${LOG_DIR}/gateway-server.log"

tail -F "${LOG_DIR}/system-server.log" "${LOG_DIR}/infra-server.log" "${LOG_DIR}/gateway-server.log"

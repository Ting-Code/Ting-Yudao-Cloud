#!/usr/bin/env bash
set -euo pipefail

SYSTEM_PORT="${SYSTEM_PORT:-58081}"
INFRA_PORT="${INFRA_PORT:-58082}"
GATEWAY_PORT="${GATEWAY_PORT:-58080}"

check_port() {
  local port="$1"
  if netstat -ano 2>/dev/null | grep -E "[:.]${port}[[:space:]].*LISTENING" >/dev/null; then
    echo "port_${port}=UP"
  else
    echo "port_${port}=DOWN"
  fi
}

check_http() {
  local name="$1"
  local url="$2"
  local code
  code="$(curl -s -o /dev/null -w "%{http_code}" "${url}" || true)"
  echo "${name}=${code}"
}

check_port "${SYSTEM_PORT}"
check_port "${INFRA_PORT}"
check_port "${GATEWAY_PORT}"

check_http "gateway_doc" "http://127.0.0.1:${GATEWAY_PORT}/doc.html"
check_http "tenant_api" "http://127.0.0.1:${GATEWAY_PORT}/admin-api/system/tenant/get-id-by-name?name=%E8%8A%8B%E9%81%93%E6%BA%90%E7%A0%81"

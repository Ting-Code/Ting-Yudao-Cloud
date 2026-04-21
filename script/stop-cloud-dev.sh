#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
PID_DIR="${PROJECT_ROOT}/logs/dev-cloud/pids"

stop_service() {
  local name="$1"
  local pid_file="${PID_DIR}/${name}.pid"
  if [[ ! -f "${pid_file}" ]]; then
    echo "[skip] ${name} pid file not found"
    return
  fi
  local pid
  pid="$(cat "${pid_file}")"
  if ps -p "${pid}" >/dev/null 2>&1; then
    echo "[stop] ${name} (pid=${pid})"
    kill "${pid}"
  else
    echo "[skip] ${name} not running (stale pid=${pid})"
  fi
  rm -f "${pid_file}"
}

stop_service "gateway-server"
stop_service "infra-server"
stop_service "system-server"

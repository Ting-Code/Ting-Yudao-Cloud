#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
LOG_DIR="${PROJECT_ROOT}/logs/dev-cloud"
PID_DIR="${PROJECT_ROOT}/logs/dev-cloud/pids"
FOLLOW_LOGS=false

for arg in "$@"; do
  if [[ "${arg}" == "--follow" ]]; then
    FOLLOW_LOGS=true
  fi
done

MVN_CMD_DEFAULT="/c/Users/Ting/tools/apache-maven-3.9.9/bin/mvn.cmd"
MVN_CMD="${MVN_CMD:-${MVN_CMD_DEFAULT}}"
GATEWAY_PORT="${GATEWAY_PORT:-58080}"
SYSTEM_PORT="${SYSTEM_PORT:-58081}"
INFRA_PORT="${INFRA_PORT:-58082}"

if [[ ! -f "${MVN_CMD}" ]] && ! command -v mvn >/dev/null 2>&1; then
  echo "Cannot find Maven command."
  echo "Please export MVN_CMD to your mvn/mvn.cmd absolute path."
  exit 1
fi

if [[ -f "${MVN_CMD}" ]]; then
  MVN="${MVN_CMD}"
else
  MVN="$(command -v mvn)"
fi

mkdir -p "${LOG_DIR}" "${PID_DIR}"
cd "${PROJECT_ROOT}"

COMMON_JVM_ARGS="-Dspring.cloud.nacos.discovery.enabled=false -Dspring.cloud.nacos.discovery.register-enabled=false -Dspring.cloud.nacos.config.enabled=false -Dspring.cloud.service-registry.auto-registration.enabled=false"
COMMON_RUN_ARGS="--spring.cloud.discovery.client.simple.instances.system-server[0].uri=http://127.0.0.1:${SYSTEM_PORT} --spring.cloud.discovery.client.simple.instances.infra-server[0].uri=http://127.0.0.1:${INFRA_PORT}"

start_service() {
  local name="$1"
  local pom="$2"
  local args="${3:-}"
  local log_file="${LOG_DIR}/${name}.log"
  local pid_file="${PID_DIR}/${name}.pid"

  if [[ -f "${pid_file}" ]] && ps -p "$(cat "${pid_file}")" >/dev/null 2>&1; then
    echo "[skip] ${name} is already running (pid=$(cat "${pid_file}"))"
    return
  fi

  echo "[start] ${name}"
  if [[ -n "${args}" ]]; then
    nohup "${MVN}" -f "${pom}" spring-boot:run -Dspring-boot.run.jvmArguments="${COMMON_JVM_ARGS}" -Dspring-boot.run.arguments="${args}" > "${log_file}" 2>&1 &
  else
    nohup "${MVN}" -f "${pom}" spring-boot:run -Dspring-boot.run.jvmArguments="${COMMON_JVM_ARGS}" > "${log_file}" 2>&1 &
  fi
  echo $! > "${pid_file}"
}

start_service "system-server" "yudao-module-system/yudao-module-system-server/pom.xml" "${COMMON_RUN_ARGS} --server.port=${SYSTEM_PORT}"
start_service "infra-server" "yudao-module-infra/yudao-module-infra-server/pom.xml" "${COMMON_RUN_ARGS} --server.port=${INFRA_PORT}"
start_service "gateway-server" "yudao-gateway/pom.xml" "${COMMON_RUN_ARGS} --server.port=${GATEWAY_PORT}"

echo
echo "Started services:"
echo "  - system-server : http://127.0.0.1:${SYSTEM_PORT}"
echo "  - infra-server  : http://127.0.0.1:${INFRA_PORT}"
echo "  - gateway-server: http://127.0.0.1:${GATEWAY_PORT}"
echo
echo "Health check:"
echo "  bash \"${SCRIPT_DIR}/check-cloud-dev.sh\""
echo
echo "Tail logs:"
echo "  tail -f \"${LOG_DIR}/gateway-server.log\""
echo "  bash \"${SCRIPT_DIR}/follow-cloud-dev.sh\""

if [[ "${FOLLOW_LOGS}" == "true" ]]; then
  echo
  echo "Following startup logs (Ctrl+C to stop viewing; services keep running)..."
  bash "${SCRIPT_DIR}/follow-cloud-dev.sh"
fi

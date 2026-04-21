#!/usr/bin/env bash
# 最简单：本机已安装 Maven 并加入 PATH 后，在仓库根目录执行：
#   ./script/start-server-dev.sh
# 若 PATH 里没有 mvn（常见于仅装了 mvn.cmd），可指定：
#   export MVN_CMD='/c/你的路径/bin/mvn.cmd'
# 一行等价命令（有 mvn 时）：
#   mvn -pl yudao-server -am clean install -DskipTests -Dspring-boot.repackage.skip=true && mvn -f yudao-server/pom.xml spring-boot:run
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

resolve_mvn() {
  if [[ -n "${MVN_CMD:-}" ]]; then
    echo "${MVN_CMD}"
    return
  fi
  if command -v mvn >/dev/null 2>&1; then
    command -v mvn
    return
  fi
  echo "未找到 Maven。请将 mvn 加入 PATH，或设置 MVN_CMD 为 mvn / mvn.cmd 的绝对路径（Git Bash 可用 /c/... 形式）。"
  exit 1
}

MVN="$(resolve_mvn)"
cd "${PROJECT_ROOT}"
echo "Starting yudao-server (using: ${MVN})..."
# 1) 依赖模块打成普通 jar，便于 dev 下扫描各模块里的 Controller
"${MVN}" -pl yudao-server -am clean install -DskipTests -Dspring-boot.repackage.skip=true
# 2) 只启动 yudao-server
"${MVN}" -f yudao-server/pom.xml spring-boot:run

$ErrorActionPreference = "Continue"

$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$PidDir = Join-Path $RepoRoot "logs\dev-cloud\pids"

function Stop-ByPidFile([string]$Name) {
  $pidFile = Join-Path $PidDir "$Name.pid"
  if (-not (Test-Path $pidFile)) {
    Write-Host "[skip] $Name pid file not found"
    return
  }
  $pidText = (Get-Content $pidFile -Raw).Trim()
  if (-not $pidText) {
    Remove-Item $pidFile -Force -ErrorAction SilentlyContinue
    Write-Host "[skip] $Name pid file empty"
    return
  }
  $procId = [int]$pidText
  try {
    Stop-Process -Id $procId -Force -ErrorAction Stop
    Write-Host "[stop] $Name (pid=$procId)"
  } catch {
    Write-Host "[skip] $Name (pid=$procId) not running"
  }
  Remove-Item $pidFile -Force -ErrorAction SilentlyContinue
}

Stop-ByPidFile "gateway-server"
Stop-ByPidFile "infra-server"
Stop-ByPidFile "system-server"

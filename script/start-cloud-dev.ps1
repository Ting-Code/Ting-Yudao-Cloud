param(
  [string]$MvnCmd = "C:\Users\Ting\tools\apache-maven-3.9.9\bin\mvn.cmd",
  [int]$GatewayPort = 58080
)

$ErrorActionPreference = "Stop"

function Ensure-Exists([string]$Path, [string]$Label) {
  if (-not (Test-Path $Path)) {
    throw "$Label not found: $Path"
  }
}

function Start-ServiceProcess([string]$Name, [string]$PomPath, [string]$Args, [string]$LogFile) {
  Write-Host "[start] $Name"
  $errFile = "$LogFile.err"
  $argList = @(
    "-f", $PomPath,
    "spring-boot:run",
    "-Dspring.cloud.nacos.discovery.enabled=false",
    "-Dspring.cloud.nacos.discovery.register-enabled=false",
    "-Dspring.cloud.nacos.config.enabled=false",
    "-Dspring.cloud.service-registry.auto-registration.enabled=false",
    "-Dspring-boot.run.arguments=$Args"
  )
  $proc = Start-Process -FilePath $MvnCmd -ArgumentList $argList -WorkingDirectory $RepoRoot -RedirectStandardOutput $LogFile -RedirectStandardError $errFile -PassThru
  $proc.Id | Out-File -FilePath (Join-Path $PidDir "$Name.pid") -Encoding ascii -Force
}

$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$LogDir = Join-Path $RepoRoot "logs\dev-cloud"
$PidDir = Join-Path $LogDir "pids"
New-Item -ItemType Directory -Force -Path $LogDir | Out-Null
New-Item -ItemType Directory -Force -Path $PidDir | Out-Null

Ensure-Exists $MvnCmd "Maven executable"

$systemPom = Join-Path $RepoRoot "yudao-module-system\yudao-module-system-server\pom.xml"
$infraPom = Join-Path $RepoRoot "yudao-module-infra\yudao-module-infra-server\pom.xml"
$gatewayPom = Join-Path $RepoRoot "yudao-gateway\pom.xml"

Ensure-Exists $systemPom "System server pom"
Ensure-Exists $infraPom "Infra server pom"
Ensure-Exists $gatewayPom "Gateway pom"

$discoveryArgs = "--spring.cloud.nacos.discovery.enabled=false --spring.cloud.nacos.discovery.register-enabled=false --spring.cloud.nacos.config.enabled=false --spring.cloud.service-registry.auto-registration.enabled=false --spring.cloud.discovery.client.simple.instances.system-server[0].uri=http://127.0.0.1:58081 --spring.cloud.discovery.client.simple.instances.infra-server[0].uri=http://127.0.0.1:58082"

Start-ServiceProcess "system-server" $systemPom $discoveryArgs (Join-Path $LogDir "system-server.log")
Start-Sleep -Seconds 2
Start-ServiceProcess "infra-server" $infraPom $discoveryArgs (Join-Path $LogDir "infra-server.log")
Start-Sleep -Seconds 2
Start-ServiceProcess "gateway-server" $gatewayPom "--server.port=$GatewayPort $discoveryArgs" (Join-Path $LogDir "gateway-server.log")

Write-Host ""
Write-Host "Started services:"
Write-Host "  system-server : 58081"
Write-Host "  infra-server  : 58082"
Write-Host "  gateway-server: $GatewayPort"
Write-Host ""
Write-Host "Run health check:"
Write-Host "  powershell -ExecutionPolicy Bypass -File `"$PSScriptRoot\check-cloud-dev.ps1`" -GatewayPort $GatewayPort"

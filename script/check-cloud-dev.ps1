param(
  [int]$GatewayPort = 58080,
  [int]$FrontendPort = 8969
)

$ErrorActionPreference = "Continue"

function Test-Port([int]$Port) {
  $rows = netstat -ano | Select-String -Pattern ":$Port\s+.*LISTENING"
  if ($rows) { return $true }
  return $false
}

function Get-Http([string]$Url) {
  try {
    return (Invoke-WebRequest -Uri $Url -UseBasicParsing -TimeoutSec 8).StatusCode
  } catch {
    return 0
  }
}

$result = [ordered]@{
  "port_58081_system" = (Test-Port 58081)
  "port_58082_infra" = (Test-Port 58082)
  "port_gateway" = (Test-Port $GatewayPort)
  "port_frontend" = (Test-Port $FrontendPort)
  "gateway_doc_status" = (Get-Http "http://127.0.0.1:$GatewayPort/doc.html")
  "tenant_api_status" = (Get-Http "http://127.0.0.1:$FrontendPort/admin-api/system/tenant/get-id-by-name?name=%E8%8A%8B%E9%81%93%E6%BA%90%E7%A0%81")
}

$result.GetEnumerator() | ForEach-Object { "{0}={1}" -f $_.Key, $_.Value } | Write-Host

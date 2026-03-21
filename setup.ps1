# setup.ps1 - Configura os arquivos .env de cada servico a partir dos .env.example
# Execute uma vez antes de usar o repositorio: .\setup.ps1

$services = @(
    "identity-users",
    "livros-service",
    "ms-pedidos",
    "notification-service",
    "payment-service"
)

Write-Host ""
Write-Host "=== CI Infra Local - Configuracao de credenciais ===" -ForegroundColor Cyan
Write-Host ""

foreach ($service in $services) {
    $envFile    = Join-Path $PSScriptRoot "$service\.env"
    $exampleFile = Join-Path $PSScriptRoot "$service\.env.example"

    if (Test-Path $envFile) {
        Write-Host "[$service] .env ja existe, pulando..." -ForegroundColor Yellow
        continue
    }

    Copy-Item $exampleFile $envFile
    Write-Host "[$service] .env criado." -ForegroundColor Green

    $repoUrl = Read-Host "  REPO_URL para $service"
    $token   = Read-Host "  RUNNER_TOKEN para $service"

    (Get-Content $envFile) `
        -replace "REPO_URL=.*",     "REPO_URL=$repoUrl" `
        -replace "RUNNER_TOKEN=.*", "RUNNER_TOKEN=$token" |
        Set-Content $envFile

    Write-Host "  -> Salvo em $envFile" -ForegroundColor DarkGray
    Write-Host ""
}

Write-Host "Pronto! Execute 'docker compose up -d' dentro de cada pasta de servico." -ForegroundColor Cyan

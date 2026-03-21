# setup.ps1 - Legado. Use preferencialmente: python manage_services.py init

Write-Host ""
Write-Host "=== CI Infra Local - Setup legado ===" -ForegroundColor Cyan
Write-Host ""

python manage_services.py init

Write-Host ""
Write-Host "Fluxo recomendado:" -ForegroundColor Cyan
Write-Host "1) Edite services.yml e preencha repo_url e runner_token de cada servico" -ForegroundColor Cyan
Write-Host "2) Rode: python manage_services.py validate" -ForegroundColor Cyan
Write-Host "3) Rode: python manage_services.py up ms-pedidos" -ForegroundColor Cyan

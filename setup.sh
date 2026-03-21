#!/usr/bin/env bash
# setup.sh - Legado. Use preferencialmente: python manage_services.py init

set -e

echo ""
echo "=== CI Infra Local - Setup legado ==="
echo ""

python manage_services.py init

echo ""
echo "Fluxo recomendado:"
echo "1) Edite services.yml e preencha repo_url e runner_token de cada servico"
echo "2) Rode: python manage_services.py validate"
echo "3) Rode: python manage_services.py up ms-pedidos"

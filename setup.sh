#!/usr/bin/env bash
# setup.sh - Configura os arquivos .env de cada servico a partir dos .env.example
# Execute uma vez antes de usar o repositorio: bash setup.sh

set -e

SERVICES=(
  "identity-users"
  "livros-service"
  "ms-pedidos"
  "notification-service"
  "payment-service"
)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo ""
echo "=== CI Infra Local - Configuracao de credenciais ==="
echo ""

for service in "${SERVICES[@]}"; do
  ENV_FILE="$SCRIPT_DIR/$service/.env"
  EXAMPLE_FILE="$SCRIPT_DIR/$service/.env.example"

  if [ -f "$ENV_FILE" ]; then
    echo "[$service] .env ja existe, pulando..."
    continue
  fi

  cp "$EXAMPLE_FILE" "$ENV_FILE"
  echo "[$service] .env criado."

  read -rp "  REPO_URL para $service: " repo_url
  read -rp "  RUNNER_TOKEN para $service: " token

  sed -i "s|REPO_URL=.*|REPO_URL=$repo_url|" "$ENV_FILE"
  sed -i "s|RUNNER_TOKEN=.*|RUNNER_TOKEN=$token|" "$ENV_FILE"

  echo "  -> Salvo em $ENV_FILE"
  echo ""
done

echo "Pronto! Execute 'docker compose up -d' dentro de cada pasta de servico."

#!/usr/bin/env bash
set -euo pipefail

# Corrige permissões do diretório de trabalho antes de rodar o runner
chown -R runner:runner /actions-runner/_work || true

# Troca para o usuário runner e executa o start.sh
exec gosu runner /actions-runner/start.sh

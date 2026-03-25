#!/usr/bin/env bash
set -euo pipefail
ls -l /actions-runner
ls -l /actions-runner/_work || echo 'Diretório _work não existe'
id
# Corrige permissões do diretório de trabalho antes de rodar o runner
chown -R runner:runner /actions-runner/_work || true

# Garante que o runner está no grupo docker e tem permissão no socket
usermod -aG docker runner
chown root:docker /var/run/docker.sock || true
chmod 660 /var/run/docker.sock || true

# Troca para o usuário runner e executa o start.sh
exec gosu runner /actions-runner/start.sh

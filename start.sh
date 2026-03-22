#!/usr/bin/env bash
set -euo pipefail

if [ -z "${REPO_URL:-}" ] || [ -z "${RUNNER_TOKEN:-}" ]; then
  echo "REPO_URL e RUNNER_TOKEN devem estar definidos no arquivo .env do servico."
  exit 1
fi

if [ ! -x "./config.sh" ] || [ ! -x "./run.sh" ]; then
  echo "Runner nao inicializado corretamente: config.sh/run.sh ausentes ou sem permissao de execucao."
  exit 1
fi

if [ ! -S "/var/run/docker.sock" ]; then
  echo "Aviso: /var/run/docker.sock nao encontrado. Jobs com Docker podem falhar."
fi

RUNNER_NAME="${RUNNER_NAME:-$(hostname)}"
RUNNER_LABELS="${RUNNER_LABELS:-self-hosted,linux,docker,multi}"

./config.sh \
  --url "${REPO_URL}" \
  --token "${RUNNER_TOKEN}" \
  --unattended \
  --replace \
  --name "${RUNNER_NAME}" \
  --labels "${RUNNER_LABELS}" \
  --work "_work"

./run.sh

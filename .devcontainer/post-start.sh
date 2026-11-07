#!/usr/bin/env bash
set -euo pipefail

# Codespaces protects forwarded ports with the owner's GitHub session.
# The desktop additionally requires its own randomly generated VNC password.
if [[ -n "${CODESPACE_NAME:-}" ]]; then
  if command -v gh >/dev/null 2>&1 && command -v timeout >/dev/null 2>&1; then
    if timeout 15 gh codespace ports visibility 6080:private \
      --codespace "$CODESPACE_NAME" >/dev/null 2>&1; then
      printf 'Porta 6080: privada.\n'
    else
      printf 'Confira na aba PORTS: a porta 6080 deve permanecer Private.\n'
    fi
  fi
fi

printf '\nPC Virtual Livre: use a porta 6080 para abrir a área de trabalho.\n'
printf 'Digite pc senha para consultar sua senha e pc ajuda para ver os comandos.\n'
pc abrir

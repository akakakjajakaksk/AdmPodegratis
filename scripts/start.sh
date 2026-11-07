#!/usr/bin/env bash
set -euo pipefail
if ! command -v docker >/dev/null 2>&1; then
  echo "Docker não encontrado. Abra este projeto no GitHub Codespaces."
  exit 1
fi
mkdir -p "$HOME/twin-pc-data"
if docker container inspect twin-pc >/dev/null 2>&1; then
  docker start twin-pc
else
  docker run -d --name twin-pc --shm-size=1g \
    -p 3001:3001 \
    -e PUID="$(id -u)" -e PGID="$(id -g)" \
    -e TZ=America/Campo_Grande \
    -v "$HOME/twin-pc-data:/config" \
    lscr.io/linuxserver/webtop:ubuntu-xfce
fi
echo "Twin PC iniciado. Abra a porta privada 3001 na aba PORTS."

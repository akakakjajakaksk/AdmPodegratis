#!/usr/bin/env bash
set -euo pipefail
umask 077

pc_user=$(cat /usr/local/etc/pc-virtual/user)
pc_user_home=$(getent passwd "$pc_user" | cut -d: -f6)
pc_uid=$(id -u "$pc_user")
pc_gid=$(id -g "$pc_user")
if [[ -z "$pc_user_home" || "$pc_user_home" != /* ]]; then
  printf 'Diretório do usuário do PC inválido.\n' >&2
  exit 1
fi
if [[ $(id -u) -ne 0 && $(id -u) -ne "$pc_uid" ]]; then
  printf 'Usuário incorreto ao preparar a autenticação do PC.\n' >&2
  exit 1
fi

pc_privileged() {
  if [[ $(id -u) -eq 0 ]]; then
    "$@"
  else
    sudo -n "$@"
  fi
}

pc_config_dir="$pc_user_home/.config/pc-virtual"
pc_password_file="$pc_config_dir/password"
if [[ ! -d "$pc_user_home/.config" ]]; then
  pc_privileged install -d -m 0700 -o "$pc_uid" -g "$pc_gid" "$pc_user_home/.config"
fi
pc_privileged install -d -m 0700 -o "$pc_uid" -g "$pc_gid" "$pc_config_dir"
if [[ -L "$pc_password_file" ]]; then
  printf 'O arquivo de senha não pode ser um link simbólico.\n' >&2
  exit 1
fi
if [[ ! -e "$pc_password_file" ]]; then
  python3 - "$pc_password_file" <<'PY'
import os
from pathlib import Path
import secrets
import string
import sys

path = Path(sys.argv[1])
password = ''.join(secrets.choice(string.ascii_letters + string.digits) for _ in range(8))
fd = os.open(path, os.O_WRONLY | os.O_CREAT | os.O_EXCL, 0o600)
with os.fdopen(fd, 'w') as output:
    output.write(password + '\n')
PY
fi
pc_privileged chown "$pc_uid:$pc_gid" "$pc_password_file"
chmod 0600 "$pc_password_file"
pc_password=$(cat "$pc_password_file")
if [[ ! "$pc_password" =~ ^[A-Za-z0-9]{8}$ ]]; then
  printf 'Senha do PC inválida. Corrija o arquivo privado antes de iniciar.\n' >&2
  exit 1
fi

pc_hash=$(mktemp "$pc_config_dir/.vnc-hash.XXXXXX")
trap 'rm -f -- "$pc_hash"' EXIT
printf '%s\n' "$pc_password" | vncpasswd -f > "$pc_hash"
if [[ ! -s "$pc_hash" ]]; then
  printf 'Não foi possível gerar a autenticação VNC.\n' >&2
  exit 1
fi
pc_privileged install -m 0600 -o "$pc_uid" -g "$pc_gid" \
  "$pc_hash" /usr/local/etc/vscode-dev-containers/vnc-passwd
unset pc_password

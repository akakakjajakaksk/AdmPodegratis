#!/usr/bin/env bash
set -euo pipefail

if [[ $(id -u) -ne 0 ]]; then
  printf 'Esta feature precisa ser instalada como root durante o build.\n' >&2
  exit 1
fi

pc_feature_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
pc_remote_user=${_REMOTE_USER:-${USERNAME:-}}
if [[ -z "$pc_remote_user" ]] || ! id "$pc_remote_user" >/dev/null 2>&1; then
  printf 'Usuário do dev container ausente ou inválido.\n' >&2
  exit 1
fi
if [[ ! -f /usr/local/share/desktop-init.sh ]]; then
  printf 'Instale a feature desktop-lite antes de desktop-auth.\n' >&2
  exit 1
fi

export DEBIAN_FRONTEND=noninteractive
apt-get update
pc_packages=(ca-certificates curl xz-utils bzip2 python3 xterm mesa-utils libdbus-glib-1-2)
for pc_candidates in 'libgtk-3-0t64 libgtk-3-0' 'libxt6t64 libxt6' 'libasound2t64 libasound2'; do
  pc_found=false
  for pc_package in $pc_candidates; do
    if apt-cache show "$pc_package" >/dev/null 2>&1; then
      pc_packages+=("$pc_package")
      pc_found=true
      break
    fi
  done
  if [[ "$pc_found" != true ]]; then
    printf 'Biblioteca gráfica indisponível: %s\n' "$pc_candidates" >&2
    exit 1
  fi
done
apt-get install -y --no-install-recommends "${pc_packages[@]}"

install -d -m 0755 /usr/local/etc/pc-virtual
printf '%s\n' "$pc_remote_user" > /usr/local/etc/pc-virtual/user
chmod 0644 /usr/local/etc/pc-virtual/user
install -m 0755 "$pc_feature_dir/pc" /usr/local/bin/pc
install -m 0755 "$pc_feature_dir/pc-vnc-auth.sh" /usr/local/share/pc-vnc-auth.sh
install -m 0755 "$pc_feature_dir/pc-desktop-setup.sh" /usr/local/share/pc-desktop-setup.sh

# Start with authentication ready, never with the feature's noPassword setting.
# A build failure here prevents producing an image with an unprotected desktop.
python3 - <<'PY'
from pathlib import Path

entrypoint = Path('/usr/local/share/desktop-init.sh')
text = entrypoint.read_text()
marker = '# PC-VIRTUAL-AUTH-BEFORE-VNC'
if marker not in text:
    if not text.startswith('#!/bin/bash\n') or 'vnc-passwd' not in text:
        raise SystemExit('Formato inesperado de desktop-lite; autenticação não aplicada.')
    bootstrap = '''# PC-VIRTUAL-AUTH-BEFORE-VNC
/usr/local/share/pc-vnc-auth.sh || exit $?
export VNC_PASSWORD=enabled
/usr/local/share/pc-desktop-setup.sh || exit $?
'''
    text = text.replace('#!/bin/bash\n', '#!/bin/bash\n' + bootstrap, 1)
    entrypoint.write_text(text)
entrypoint.chmod(0o755)
PY

# Mozilla supplies a standalone browser; no Snap daemon or disabled TLS checks.
if [[ ! -x /opt/firefox/firefox ]]; then
  case $(dpkg --print-architecture) in
    amd64) pc_firefox_os=linux64 ;;
    arm64) pc_firefox_os=linux64-aarch64 ;;
    *) printf 'Arquitetura não suportada pelo instalador Firefox.\n' >&2; exit 1 ;;
  esac
  pc_download_dir=$(mktemp -d)
  trap 'rm -rf -- "$pc_download_dir"' EXIT
  curl --fail --location --retry 3 --proto '=https' --tlsv1.2 \
    "https://download.mozilla.org/?product=firefox-latest-ssl&os=${pc_firefox_os}&lang=pt-BR" \
    --output "$pc_download_dir/firefox.tar"
  tar --extract --file "$pc_download_dir/firefox.tar" \
    --directory "$pc_download_dir" --no-same-owner
  if [[ ! -x "$pc_download_dir/firefox/firefox" ]]; then
    printf 'O download oficial não contém o executável Firefox esperado.\n' >&2
    exit 1
  fi
  install -d -m 0755 /opt
  mv -- "$pc_download_dir/firefox" /opt/firefox
  rm -rf -- "$pc_download_dir"
  trap - EXIT
fi
ln -sfn /opt/firefox/firefox /usr/local/bin/firefox
install -d -m 0755 /opt/firefox/defaults/pref
cat > /opt/firefox/defaults/pref/pc-virtual.js <<'EOF'
// Defaults only: the owner can change these in Firefox settings.
pref("browser.download.folderList", 2);
pref("browser.download.dir", "/workspaces/arquivos-pc/Downloads");
pref("browser.download.useDownloadDir", true);
pref("browser.shell.checkDefaultBrowser", false);
pref("browser.aboutwelcome.enabled", false);
pref("browser.startup.page", 0);
pref("browser.startup.homepage", "about:blank");
EOF
chmod 0644 /opt/firefox/defaults/pref/pc-virtual.js
cat > /usr/share/applications/pc-firefox.desktop <<'EOF'
[Desktop Entry]
Type=Application
Name=Firefox
Comment=Navegador da internet
Exec=/usr/local/bin/firefox %u
Icon=/opt/firefox/browser/chrome/icons/default/default128.png
Terminal=false
Categories=Network;WebBrowser;
MimeType=text/html;x-scheme-handler/http;x-scheme-handler/https;
EOF
chmod 0644 /usr/share/applications/pc-firefox.desktop
apt-get clean
rm -rf /var/lib/apt/lists/*
printf 'PC Virtual Livre instalado. A senha será criada somente ao iniciar o container.\n'

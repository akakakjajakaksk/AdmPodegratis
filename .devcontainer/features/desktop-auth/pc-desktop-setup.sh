#!/usr/bin/env bash
set -euo pipefail

pc_user=$(cat /usr/local/etc/pc-virtual/user)
pc_user_home=$(getent passwd "$pc_user" | cut -d: -f6)
pc_uid=$(id -u "$pc_user")
pc_gid=$(id -g "$pc_user")

pc_privileged() {
  if [[ $(id -u) -eq 0 ]]; then "$@"; else sudo -n "$@"; fi
}

pc_privileged install -d -m 0755 -o "$pc_uid" -g "$pc_gid" \
  /workspaces/arquivos-pc /workspaces/arquivos-pc/Downloads \
  /workspaces/arquivos-pc/Documentos "$pc_user_home/.fluxbox"

# Leave personal customizations intact after the first start.
if [[ ! -e "$pc_user_home/.fluxbox/.pc-virtual-configured" ]]; then
  cat > "$pc_user_home/.fluxbox/menu" <<'EOF'
[begin] (Meu PC)
  [exec] (Internet — Firefox) { firefox } <>
  [exec] (Meus arquivos) { nautilus /workspaces/arquivos-pc } <>
  [exec] (Terminal) { xterm -fa 'DejaVu Sans Mono' -fs 12 -e bash -il } <>
  [exec] (Editor de texto) { mousepad } <>
  [separator]
  [submenu] (Configurações)
    [exec] (Tela 1280 x 720) { pc resolucao 1280x720 } <>
    [exec] (Tela 1024 x 600) { pc resolucao 1024x600 } <>
    [exec] (Uso de processador e memória) { xterm -fa 'DejaVu Sans Mono' -fs 12 -e htop } <>
    [exec] (Ajuda do PC) { xterm -fa 'DejaVu Sans Mono' -fs 12 -hold -e pc ajuda } <>
  [end]
  [separator]
  [config] (Aparência e janelas)
[end]
EOF
  cat > "$pc_user_home/.fluxbox/init" <<'EOF'
session.configVersion: 13
session.menuFile: ~/.fluxbox/menu
session.keyFile: ~/.fluxbox/keys
session.styleFile: /usr/share/fluxbox/styles/qnx-photon
session.screen0.workspaces: 1
session.screen0.workspaceNames: Meu PC
session.screen0.workspacewarping: false
session.screen0.toolbar.visible: true
session.screen0.toolbar.autoHide: false
session.screen0.toolbar.widthPercent: 100
session.screen0.toolbar.height: 38
session.screen0.toolbar.placement: BottomCenter
session.screen0.toolbar.tools: RootMenu, iconbar, systemtray, clock
session.screen0.strftimeFormat: %d/%m  %H:%M
session.screen0.defaultDeco: NORMAL
session.screen0.fullMaximization: false
session.screen0.clickRaises: true
EOF
  # Keep the window manager's mouse controls for moving/resizing windows.
  pc_default_keys=''
  for pc_candidate in /etc/X11/fluxbox/keys /usr/share/fluxbox/keys /etc/fluxbox/keys; do
    if [[ -f "$pc_candidate" ]]; then pc_default_keys="$pc_candidate"; break; fi
  done
  if [[ -n "$pc_default_keys" ]]; then
    cp -- "$pc_default_keys" "$pc_user_home/.fluxbox/keys"
  else
    cat > "$pc_user_home/.fluxbox/keys" <<'EOF'
OnDesktop Mouse1 :HideMenus
OnDesktop Mouse3 :RootMenu
OnWindow Mouse1 :MacroCmd {Focus} {Raise}
OnTitlebar Mouse1 :MacroCmd {Focus} {Raise} {ActivateTab}
OnTitlebar Move1 :StartMoving
OnTitlebar Mouse3 :WindowMenu
OnLeftGrip Move1 :StartResizing bottomleft
OnRightGrip Move1 :StartResizing bottomright
OnWindow Mod1 Mouse1 :MacroCmd {Focus} {Raise} {StartMoving}
OnWindow Mod1 Mouse3 :MacroCmd {Focus} {Raise} {StartResizing NearestCorner}
EOF
  fi
  cat >> "$pc_user_home/.fluxbox/keys" <<'EOF'
Control Escape :RootMenu
Mod1 F4 :Close
Mod1 Tab :NextWindow {groups}
Control Mod1 t :Exec xterm -fa 'DejaVu Sans Mono' -fs 12 -e bash -il
EOF
  cat > "$pc_user_home/.fluxbox/startup" <<'EOF'
#!/usr/bin/env bash
xsetroot -solid '#142438'
exec fluxbox
EOF
  chmod 0755 "$pc_user_home/.fluxbox/startup"
  touch "$pc_user_home/.fluxbox/.pc-virtual-configured"
  pc_privileged chown -R "$pc_uid:$pc_gid" "$pc_user_home/.fluxbox"
fi

# A visible home-folder shortcut keeps files outside the repository and persistent
# through container rebuilds. Never replace an existing personal directory.
if [[ ! -e "$pc_user_home/Meus arquivos" && ! -L "$pc_user_home/Meus arquivos" ]]; then
  ln -s /workspaces/arquivos-pc "$pc_user_home/Meus arquivos"
  pc_privileged chown -h "$pc_uid:$pc_gid" "$pc_user_home/Meus arquivos"
fi

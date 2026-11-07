"""Verifica uma instância local de teste. Não cria nem consome um Codespace.

Requer Python + Playwright e o container já iniciado com desktop-auth.
PC_TEST_CONTAINER e PC_TEST_URL selecionam APENAS o alvo local de teste.
"""
import os
import re
import subprocess
import time
from pathlib import Path
from playwright.sync_api import sync_playwright

container = os.environ.get('PC_TEST_CONTAINER', 'codex-pc-virtual-test')
url = os.environ.get('PC_TEST_URL', 'http://127.0.0.1:16080')
user = os.environ.get('PC_TEST_USER', 'vscode')

def docker(*args):
    return subprocess.check_output(
        ['docker', '--host=unix:///var/run/docker.sock', 'exec', '-u', user,
         container, *args], text=True
    ).strip()

def window_titles():
    # Query managed clients directly: walking Firefox's transient child windows
    # with xwininfo -tree races with windows being created and destroyed.
    return docker('python3', '-c', '''
import re, subprocess
clients = subprocess.check_output(['xprop', '-root', '_NET_CLIENT_LIST'], text=True)
for window in re.findall(r'0x[0-9a-fA-F]+', clients):
    result = subprocess.run(['xprop', '-id', window, '_NET_WM_NAME', 'WM_NAME'],
                            capture_output=True, text=True)
    print(result.stdout)
''')

password = docker('pc', 'senha')
assert len(password) == 8 and password.isascii()
assert docker('sh', '-c', 'stat -c %a "$HOME/.config/pc-virtual/password"') == '600'
assert docker('sh', '-c', 'stat -c %a /usr/local/etc/vscode-dev-containers/vnc-passwd') == '600'
assert '6080' in docker('pc', 'url')
docker('python3', '-c', '''
import socket
with socket.create_connection(('127.0.0.1', 5901), timeout=5) as s:
    version = s.recv(12)
    assert version.startswith(b'RFB '), version
    s.sendall(b'RFB 003.008\\n')
    count = s.recv(1)[0]
    security_types = s.recv(count)
    assert count > 0 and 1 not in security_types, security_types
''')

with sync_playwright() as p:
    browser = p.chromium.launch(
        executable_path=os.environ.get('PC_TEST_CHROMIUM', '/usr/bin/chromium'),
        headless=True, args=['--no-sandbox', '--disable-dev-shm-usage']
    )
    context = browser.new_context(viewport={'width': 915, 'height': 412},
                                  is_mobile=True, has_touch=True)
    page = context.new_page()
    page.goto(url + '/vnc.html?autoconnect=1&resize=scale&quality=6&compression=2',
              wait_until='domcontentloaded')
    password_input = page.locator('#noVNC_password_input')
    password_input.wait_for(state='visible', timeout=30000)
    password_input.fill(password)
    page.locator('#noVNC_credentials_button').click()
    page.wait_for_function("document.documentElement.classList.contains('noVNC_connected')", timeout=30000)
    canvas = page.locator('#noVNC_container canvas')
    assert canvas.evaluate('(e) => e.width > 0 && e.height > 0')
    box = canvas.bounding_box()
    assert box and box['width'] <= 916 and box['height'] <= 413
    # Aplicativo real produz uma janela na mesma sessão que o navegador vê.
    # Este container é descartável e exclusivo do teste; remova janelas antigas.
    docker('sh', '-c', 'pkill -x xterm || true')
    docker('sh', '-c', 'nohup xterm -title "Desktop funcionando" -geometry 65x15+40+40 -e /bin/bash --noprofile --norc >/tmp/pc-test-xterm.log 2>&1 </dev/null &')
    page.wait_for_timeout(2000)
    assert 'Desktop funcionando' in window_titles()
    def window_position():
        info = docker('xwininfo', '-name', 'Desktop funcionando')
        return tuple(int(re.search(r'Absolute upper-left ' + axis + r':\s+(-?\d+)', info).group(1))
                     for axis in ('X', 'Y'))
    before = window_position()
    scale = box['width'] / canvas.evaluate('(e) => e.width')
    x = box['x'] + (before[0] + 120) * scale
    y = box['y'] + (before[1] - 8) * scale
    page.mouse.move(x, y)
    page.mouse.down()
    page.mouse.move(x + 70, y + 45, steps=12)
    page.mouse.up()
    page.wait_for_timeout(500)
    assert window_position() != before, 'Arrastar a janela pelo título não funcionou.'
    artifacts = Path(os.environ.get('PC_TEST_ARTIFACTS', '/tmp/pc-virtual-test-artifacts'))
    artifacts.mkdir(parents=True, exist_ok=True)
    page.screenshot(path=str(artifacts / 'desktop-celular.png'))
    page.touchscreen.tap(box['x'] + 19 * scale,
                         box['y'] + (canvas.evaluate('(e) => e.height') - 22) * scale)
    page.wait_for_timeout(350)
    page.screenshot(path=str(artifacts / 'menu-celular.png'))
    page.keyboard.press('Escape')
    docker('pc', 'navegador')
    for _ in range(20):
        if 'Firefox' in window_titles():
            break
        time.sleep(1)
    else:
        raise AssertionError('Firefox não abriu uma janela na área de trabalho.')
    docker('python3', '-c', '''
from pathlib import Path
Path('/workspaces/arquivos-pc/teste-navegador.html').write_text(
    '<title>PC Virtual funcionando</title><body style="background:#142438;color:white;font:24px sans-serif">'
    '<h1>Firefox funcionando</h1><p>Teste do navegador no desktop Linux.</p></body>'
)
''')
    docker('firefox', '--new-tab', 'file:///workspaces/arquivos-pc/teste-navegador.html')
    for _ in range(20):
        if 'PC Virtual funcionando' in window_titles():
            break
        time.sleep(1)
    else:
        raise AssertionError('Conclua as boas-vindas do Firefox no container de teste e repita a verificação da página.')
    page.wait_for_timeout(2000)
    page.screenshot(path=str(artifacts / 'firefox-celular.png'))
    browser.close()
print('PASS: autenticação VNC, senha privada, desktop móvel, arraste de janela e Firefox.')

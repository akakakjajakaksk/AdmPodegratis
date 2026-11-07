"""Teste em container descartável: credenciais e documentos sobrevivem à retomada."""
import os
import subprocess
import time
import urllib.request

container = os.environ.get('PC_TEST_CONTAINER', 'codex-pc-virtual-test')
user = os.environ.get('PC_TEST_USER', 'vscode')
url = os.environ.get('PC_TEST_URL', 'http://127.0.0.1:16080')
command = ['docker', '--host=unix:///var/run/docker.sock']
def docker(*args):
    return subprocess.check_output(command + list(args), text=True).strip()
def desktop(*args):
    return docker('exec', '-u', user, container, *args)

password_before = desktop('pc', 'senha')
desktop('python3', '-c', "from pathlib import Path; Path('/workspaces/arquivos-pc/teste-retomada.txt').write_text('arquivo preservado')")
docker('restart', '--time', '5', container)
opener = urllib.request.build_opener(urllib.request.ProxyHandler({}))
for _ in range(30):
    try:
        with opener.open(url + '/vnc.html', timeout=2) as response:
            if response.status == 200:
                break
    except OSError:
        pass
    time.sleep(1)
else:
    raise AssertionError('Desktop não retomou em 30 segundos.')
assert password_before == desktop('pc', 'senha'), 'Senha mudou ao reiniciar.'
assert desktop('cat', '/workspaces/arquivos-pc/teste-retomada.txt') == 'arquivo preservado'
assert 'Desktop: ativo' in desktop('pc', 'status')
print('PASS: desktop reinicia, preserva a senha e mantém os documentos.')

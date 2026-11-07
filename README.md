# Twin PC — desktop Linux no navegador

Projeto para executar um desktop Ubuntu XFCE no GitHub Codespaces e acessá-lo pelo celular.

## Iniciar
1. Clique em **Code > Codespaces > Create codespace on main**.
2. Espere o ambiente abrir.
3. No terminal, execute: `bash scripts/start.sh`
4. Na aba **PORTS**, abra a porta **3001** (visibilidade **Private**).
5. Use o desktop no navegador do celular.

## Comandos
- Iniciar: `bash scripts/start.sh`
- Parar: `bash scripts/stop.sh`
- Logs: `docker logs -f twin-pc`
- Terminal do container: `docker exec -it twin-pc bash`

Os dados em `/config` são armazenados no diretório `$HOME/twin-pc-data` do Codespace. Faça backup antes de excluir o Codespace.

## Limitações
GitHub Codespaces não é um PC gamer: não oferece GPU dedicada garantida, jogos Windows e anti-cheat podem não funcionar e o serviço tem cotas e suspensão por inatividade. A porta deve permanecer privada. Não publique o desktop sem autenticação. Esta configuração é inicial e não foi testada em um Codespace real.

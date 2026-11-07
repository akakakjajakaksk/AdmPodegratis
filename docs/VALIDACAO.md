# Validação

Testado em 7 de novembro de 2026, em um contêiner local Ubuntu 24.04 com a instalação oficial do desktop-lite 1.2.10 e a feature deste projeto. A imagem `universal:2` e a inicialização dentro da conta do GitHub ainda precisam ser verificadas no primeiro Codespace.

Verificações aprovadas:

- Cinco testes de argumentos do comando `pc`, incluindo instalação sem interpretação de texto como comandos de shell.
- Login no noVNC com senha aleatória; o VNC não oferece conexão sem autenticação.
- Senha e hash com permissão 0600, fora do repositório.
- Desktop visível em viewport móvel de 915 × 412, menu por toque e janela de terminal que pode ser arrastada.
- Reinício do contêiner preserva a senha e os documentos de teste.
- Usuário do desktop tem acesso a sudo e consegue gravar em `/workspaces/arquivos-pc`.

O Firefox abriu e renderizou um arquivo HTML local após concluir a tela inicial de boas-vindas. Na primeira abertura, conclua essa tela antes de navegar. Não foi executado benchmark de jogos ou FPS.

Para repetir os testes de argumentos:

```bash
python3 -m unittest discover -s tests -p 'test_*.py' -v
```

`tests/browser_smoke.py` e `tests/restart_smoke.py` são testes de integração para um contêiner Docker descartável, já iniciado e configurado, com Playwright instalado no executor. Eles não criam um Codespace. O teste gráfico fecha janelas de terminal desse contêiner de teste; não execute em uma sessão de uso pessoal.

Antes do teste de páginas, abra o Firefox no desktop de teste e conclua as boas-vindas. Os testes não alteram nem aceitam automaticamente os termos do navegador em um Codespace do usuário.

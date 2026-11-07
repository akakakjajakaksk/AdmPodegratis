# PC Virtual Livre

Uma área de trabalho Linux real, acessível pelo navegador do celular: arquivos, terminal, editor de texto, Firefox e instalação de programas. O código fica neste repositório; o computador executa no **GitHub Codespaces**.

[**Abrir meu PC no Codespaces**](https://github.com/codespaces/new?repo=1449595913&ref=pc-virtual-livre)

O projeto é gratuito e aberto. O Codespaces tem uma cota gratuita limitada; confira a seção de custos antes de criar a máquina.

## Começar no Samsung A07

1. Entre na sua conta do GitHub e abra o botão acima. Para priorizar desempenho, escolha **4 núcleos / 16 GB**, se o GitHub oferecer essa opção. Para a cota durar mais, use **2 núcleos / 8 GB**. A configuração do projeto aceita a opção menor.
2. Aguarde a criação e a preparação do ambiente. Na primeira vez, o GitHub precisa baixar e instalar os componentes.
3. No terminal do Codespaces, execute `pc senha` para consultar a senha do desktop.
4. Execute `pc abrir` para obter o endereço. Também é possível abrir a aba **Ports / Portas**, localizar **6080** e tocar em **Open in Browser / Abrir no navegador**. A porta deve permanecer **Private / Privada**.
5. No noVNC, toque em **Connect / Conectar**, se necessário, e digite a senha. Gire o celular para a horizontal. O menu lateral do noVNC permite abrir o teclado virtual e ajustar a tela.

Dentro do desktop, use o menu da barra para abrir os programas. O guia [COMECE AQUI](docs/COMECE-AQUI.md) explica os controles e como guardar arquivos.

## Comandos úteis

Execute estes comandos no terminal do Codespaces ou no terminal do desktop:

| Comando | Função |
| --- | --- |
| `pc abrir` | Exibe o endereço do desktop. |
| `pc senha` | Mostra a senha desta máquina. |
| `pc status` | Consulta o estado do ambiente. |
| `pc navegador` | Abre o Firefox na área de trabalho. |
| `pc resolucao 1280x720` | Ajusta o tamanho da área de trabalho. |
| `pc instalar vlc` | Instala um pacote Linux disponível nos repositórios APT. |
| `pc parar` | Solicita a parada do Codespace para encerrar o consumo de processamento. |
| `pc ajuda` | Mostra os comandos disponíveis. |

É possível usar `sudo apt-get` diretamente. Instalar pacotes grandes consome espaço da cota do Codespaces.

## Arquivos e persistência

Guarde seus arquivos em **`/workspaces/arquivos-pc`**. Essa pasta permanece ao parar, retomar ou reconstruir o contêiner do mesmo Codespace. **Excluir o Codespace exclui seus arquivos**: baixe uma cópia antes.

Instalações manuais de programas e alterações fora de `/workspaces` podem desaparecer ao reconstruir o contêiner. Para repetir uma instalação automaticamente, acrescente os pacotes à configuração do projeto. Para salvar código no GitHub, use commits; não envie senhas ou arquivos pessoais junto com o projeto.

## Uso sem gastar

- Contas pessoais **GitHub Free** incluem **120 horas-núcleo e 15 GB-mês** de armazenamento por mês. A cota de armazenamento também pode acabar antes da de processamento.
- Mais núcleos podem melhorar tarefas de processamento, mas consomem a cota mais rapidamente. A escolha depende das máquinas que o GitHub disponibiliza para sua conta e este repositório; este projeto não contrata uma máquina maior automaticamente.
- Sem uma forma de pagamento válida, o GitHub bloqueia o uso quando a cota termina. Se sua conta já tem pagamento configurado, confira os controles de orçamento e o bloqueio de uso pago **antes de criar o Codespace**. O projeto não consegue configurar a cobrança da sua conta.
- Ao terminar, execute `pc parar` ou pare a máquina em [github.com/codespaces](https://github.com/codespaces). Fechar a aba do navegador não equivale a parar a máquina.
- Um Codespace parado ainda ocupa armazenamento. Faça backup e exclua o ambiente quando não precisar mais dele.

Com as 120 horas-núcleo inteiras disponíveis, a estimativa de tempo de uso é:

| Máquina, se disponível | Tempo de uso aproximado |
| --- | --- |
| 2 núcleos / 8 GB | 60 horas |
| 4 núcleos / 16 GB | 30 horas |
| 8 núcleos | 15 horas |

Essa escolha não acrescenta uma GPU e não garante FPS em jogos.

Valores e regras podem mudar: consulte a [documentação oficial de cobrança](https://docs.github.com/en/billing/concepts/product-billing/github-codespaces) e os [orçamentos do GitHub](https://docs.github.com/en/billing/how-tos/set-up-budgets).

## O que este PC consegue fazer

O ambiente usa Linux, Fluxbox, TigerVNC e noVNC. A imagem padrão do Codespaces e as Dev Container Features reduzem a configuração necessária. Você tem acesso ao terminal e a `sudo` **dentro do contêiner**, podendo instalar aplicativos Linux compatíveis com seus recursos.

O Codespaces não fornece uma GPU para este projeto: o GitHub [aposentou as máquinas com GPU em 29 de agosto de 2025](https://github.blog/changelog/2025-08-01-upcoming-deprecation-of-gpu-machine-type-in-codespaces/). Portanto, **não há promessa de GTA V, qualquer jogo, 60 FPS ou FPS alto**. É um desktop Linux, e programas Windows não passam a funcionar automaticamente nele. A conexão VNC deste projeto transmite imagem e controles, sem áudio.

O Codespaces é um ambiente de desenvolvimento com cota, suspensão por inatividade e políticas próprias; este projeto não fornece um servidor permanente.

## Acesso e licença

O acesso web usa a porta privada **6080**, com autenticação do GitHub e uma senha VNC aleatória de 8 caracteres gerada para a máquina. A senha fica fora do repositório. A porta VNC **5901** não precisa ser publicada.

O código deste projeto usa a [licença MIT](LICENSE). Linux, os programas instalados e os componentes utilizados mantêm suas próprias licenças. O repositório pode ser modificado e executado em outro ambiente compatível com Dev Containers; desempenho e disponibilidade dependem desse ambiente.

## Testes

Veja os resultados e os limites da verificação em [VALIDAÇÃO](docs/VALIDACAO.md). Esta versão fica na branch `pc-virtual-livre`; a configuração anterior em `main` foi preservada.

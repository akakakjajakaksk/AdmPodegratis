# Comece aqui pelo celular

## 1. Criar a máquina

Abra [Criar Codespace](https://github.com/codespaces/new?repo=1449595913&ref=pc-virtual-livre) no Chrome e entre na sua conta do GitHub. Para priorizar desempenho, escolha **4 núcleos / 16 GB**, se essa opção estiver disponível. Com as 120 horas-núcleo gratuitas inteiras, isso corresponde a aproximadamente **30 horas de uso**. Para a cota durar mais, **2 núcleos / 8 GB** permitem aproximadamente **60 horas**. Antes de confirmar, confira o saldo e as configurações de cobrança da sua conta.

Se o GitHub abrir a criação rápida sem uma escolha de máquina, use as opções de criação do Codespace no repositório para consultar as máquinas disponíveis. O projeto aceita a máquina de 2 núcleos, e a conta pode não ter acesso às opções maiores. Aumentar os núcleos não cria uma GPU.

Aguarde o editor terminar de abrir e a preparação do ambiente concluir. A primeira criação pode levar vários minutos. Não crie outra máquina enquanto espera: cada Codespace tem seu próprio consumo e armazenamento.

## 2. Entrar na área de trabalho

No editor do Codespaces, abra **Terminal → New Terminal / Novo terminal**, se ainda não houver um terminal visível, e execute:

```bash
pc senha
pc abrir
```

Copie a senha e abra o endereço informado. Uma alternativa é ir à aba **Ports / Portas**, localizar a porta **6080** e escolher **Open in Browser / Abrir no navegador**. Mantenha a visibilidade em **Private / Privada** e use a mesma conta do GitHub no navegador.

Se necessário, toque em **Connect / Conectar** e informe a senha. Não coloque a senha no endereço nem em um arquivo do repositório.

Para a imagem caber na tela sem aumentar a resolução do servidor, o caminho do visualizador é:

```text
/vnc.html?autoconnect=true&resize=scale&quality=6&compression=2
```

Esse caminho vai depois do domínio da porta 6080. O comando `pc abrir` prepara o link para você.

## 3. Usar no A07

- Gire o celular para a horizontal para ganhar espaço.
- Toque na aba lateral do noVNC para mostrar os controles. O botão de teclado permite digitar usando o teclado do Android.
- Abra os programas pelo menu da barra da área de trabalho. Ele evita depender de um clique com o botão direito.
- O Firefox já está incluído. Abra pelo menu ou execute `pc navegador` no terminal.
- Se precisar enviar teclas especiais, como `Ctrl`, use os controles do noVNC. Um teclado e um mouse Bluetooth também podem facilitar o uso.
- Para copiar texto entre os ambientes, use o controle de área de transferência do noVNC, quando disponível; o navegador pode pedir permissão.

A configuração inicial usa uma resolução leve. Você pode ajustar no terminal:

```bash
pc resolucao 1280x720
```

Uma resolução maior aumenta o trabalho de processamento e transmissão, sem criar mais potência.

## 4. Instalar programas

Use nomes de pacotes Linux disponíveis nos repositórios do sistema. Por exemplo:

```bash
pc instalar vlc
```

Também é possível usar `sudo apt-get install`. A disponibilidade depende do pacote, da arquitetura e dos recursos da máquina. Arquivos `.exe` do Windows não são instaladores Linux; compatibilidade com jogos Windows não é garantida.

O desktop não recebe áudio por VNC, mesmo quando um aplicativo reproduz som no servidor.

## 5. Salvar e sair

Guarde documentos e downloads importantes em:

```text
/workspaces/arquivos-pc
```

Os arquivos dessa pasta permanecem nas paradas, retomadas e reconstruções do mesmo Codespace. Baixe um backup antes de excluir a máquina. Instalações manuais e alterações no sistema fora de `/workspaces` podem desaparecer numa reconstrução.

Ao terminar, execute:

```bash
pc parar
```

Se o comando não conseguir parar a máquina, abra [seus Codespaces](https://github.com/codespaces) e escolha **Stop codespace / Parar Codespace** no menu da máquina. A área de trabalho desconectar quando o Codespace parar é esperado. Fechar somente a aba do desktop não interrompe imediatamente o consumo.

## Se algo não abrir

| Situação | O que fazer |
| --- | --- |
| Não aparece a porta 6080 | Espere a preparação concluir e execute `pc status`. Veja se houve erro no terminal da criação. |
| A página pede login do GitHub | Entre com a conta dona do Codespace; a porta é privada. |
| A senha não funciona | Consulte `pc senha` de novo. A reconstrução do ambiente pode gerar outra senha. |
| A máquina parou | Retome o Codespace em [github.com/codespaces](https://github.com/codespaces), aguarde o desktop iniciar e use `pc abrir`. |
| Acabou a cota | Pare a máquina e confira a data de renovação no GitHub. Criar outro Codespace não renova a cota da conta. |
| Um jogo trava ou não abre | Confira `pc status` e os requisitos do jogo. O Codespaces não tem GPU para este projeto; mudar a resolução não garante compatibilidade nem FPS. |

Se estiver enviando este projeto para outro repositório, mantenha a pasta oculta **`.devcontainer`** e seus arquivos na raiz. Um ZIP enviado como um único arquivo ao GitHub não configura o Codespace: é necessário extrair e enviar a estrutura, ou usar Git. Atualize os links de criação do Codespace para o novo repositório.

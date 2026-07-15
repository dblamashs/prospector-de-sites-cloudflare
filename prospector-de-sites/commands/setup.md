---
description: Configura o plugin — assinatura, preferências e conexão com a Cloudflare (roda uma vez)
---

Configure o ambiente do Prospector de Sites. Siga esta ordem:

## 1. Pasta de trabalho

Verifique se há uma pasta do usuário conectada. Se não houver, peça para conectar uma pasta (ex.: "Clientes") usando a ferramenta de solicitação de pasta — tudo (config, leads e sites criados) será salvo nela para persistir entre sessões.

## 2. Verificar config existente

Procure prospector-config.json na pasta conectada. Se existir, mostre um resumo (sem exibir o token) e pergunte o que o usuário quer atualizar. Se não existir, colete os dados abaixo.

## 3. Dados do usuário (perguntar via AskUserQuestion / formulário)

Colete: assinatura da proposta (nome completo, como quer se apresentar, ex. "Designer de páginas de alta conversão", e WhatsApp/telefone de contato); nichos padrão de prospecção (sugira nutricionistas, psicólogos, advogados e psiquiatras como ponto de partida, mas deixe o usuário editar livremente); cidade/região padrão; leads qualificados por busca (padrão 10); modo de envio da proposta (padrão "criar rascunho no Gmail para revisão", recomendado; alternativa: enviar direto).

## 4. Conexão com a Cloudflare

Pergunte se o usuário já tem conta na Cloudflare (gratuita, cloudflare.com).

Se ainda não tem: explique brevemente que é só criar a conta (grátis, sem cartão) e que depois de criada deve voltar e rodar /setup de novo. Salve o config parcial e encerre.

Se já tem: NÃO colete nenhum dado da Cloudflare pelo chat (nem account ID, e JAMAIS o API Token). Tudo vai num lugar só, a aba Configurações do dashboard. Primeiro instrua: abra o dashboard (iniciar-dashboard.bat na pasta conectada) e vá até a aba Configurações, seção Conexão Cloudflare. Lá ele preenche dois campos: Account ID (em dash.cloudflare.com, barra lateral direita da tela inicial, "Account ID") e o API Token — oriente a criar em dash.cloudflare.com, ícone de perfil, API Tokens, Create Token, usando o template "Developer Services" (cobre Pages/Workers/D1/KV/R2 — evite "Write all resources", que é acesso total à conta). Ao clicar em "Salvar conexão", tudo vai do navegador direto pro prospector-config.json no computador dele, sem passar pelo chat. Depois peça para ele avisar quando salvar ("salvei") — aí você LÊ o config (verificando que os campos estão preenchidos, sem nunca exibir o token) e roda o teste de conexão.

Nunca exiba, imprima ou registre o token em nenhuma saída. Se ele preferir, editar o prospector-config.json na mão também vale.

Atenção a gravação instável: em alguns ambientes a escrita do prospector-config.json pelo dashboard pode ficar truncada/corrompida no meio (json inválido). Ao ler o config para verificar, sempre valide que é JSON parseável até o fim; se não for, peça para o usuário salvar de novo pelo dashboard antes de prosseguir.

## 5. Salvar e testar

Salve tudo em prospector-config.json na pasta conectada, neste formato:

```json
{
  "assinatura": { "nome": "", "apresentacao": "", "whatsapp": "" },
  "prospeccao": { "nichos": ["nutricionistas", "psicologos", "advogados", "psiquiatras"], "cidade": "", "leadsPorBusca": 10 },
  "envio": { "modo": "rascunho" },
  "cloudflare": { "apiToken": "", "accountId": "" }
}
```

Se os dados da Cloudflare foram informados, teste a conexão seguindo a skill deploy-cloudflare: o teste roda via o script local, não direto do chat — o sandbox não alcança a API da Cloudflare (bloqueio de proxy confirmado). Garanta os arquivos do publicador (publicar-cloudflare.bat/.ps1/.command) na pasta conectada, escreva fila-publicacao.txt apontando para um projeto Astro mínimo de teste ("Funcionou!") como prospector-teste, peça UM duplo clique, e depois leia publicador-log.txt e informe a URL https://prospector-teste.pages.dev ao usuário. Se o teste falhar, diagnostique pelo log (token sem escopo Pages, account ID incorreto, wrangler/node ausente no computador do usuário) antes de concluir. Depois do teste, pode orientar a apagar o projeto rodando npx wrangler pages project delete prospector-teste --account-id="[accountId]" no mesmo terminal local.

## 6. Dashboard inicial

Siga a seção "Setup" da skill dashboard-leads: copie dashboard-server.py e iniciar-dashboard.bat para a raiz da pasta conectada, crie o banco prospector.db (schema da skill) e gere o dashboard.html do template. Explique ao usuário: duplo clique em iniciar-dashboard.bat abre o painel completo em http://localhost:8765 com edição/exclusão salvando no banco (requer Python no Windows; sem ele, o dashboard.html abre no modo leitura).

## 7. Entregar o manual e os scripts

Copie da pasta do plugin para a pasta conectada (sobrescrevendo versões antigas): manual.html (manual do usuário) e os arquivos do publicador conforme o sistema do usuário (skill deploy-cloudflare, references) — Windows: publicar-cloudflare.bat + publicar-cloudflare.ps1; Mac: publicar-cloudflare.command; mais o iniciador do dashboard certo (iniciar-dashboard.bat ou .command). O teste de conexão do item 5 já usa esse fluxo, então nada extra a instalar aqui além de garantir que os arquivos estão na pasta. Apresente o manual.html ao usuário com a frase: "Esse é o seu manual — guarda ele que responde 90% das dúvidas."

## 8. Encerrar

Confirme o que foi salvo e explique o ciclo (guiando SEMPRE o próximo passo ao fim de cada comando): /prospectar, depois /redesenhar, depois /publicar, depois /proposta, com /editor opcional para ajustes manuais e o dashboard.html como painel de controle de tudo.

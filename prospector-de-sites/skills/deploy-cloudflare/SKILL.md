---
name: deploy-cloudflare
description: Esta skill deve ser usada ao publicar páginas na Cloudflare — deploy via Wrangler CLI em Cloudflare Pages, um projeto por cliente, criação da URL pública (*.pages.dev) e domínio customizado quando o cliente fecha. Acione quando o usuário disser "publicar", "subir o site", "colocar no ar", "deploy", "cloudflare" ou rodar /publicar ou o teste de conexão do /setup.
---

# Deploy na Cloudflare (Pages, script local)

Publicar cada site como um projeto Cloudflare Pages isolado — https://[slug].pages.dev.

## Por que roda no computador do usuário, não no sandbox

O sandbox onde este agente executa tem uma lista de domínios de rede liberados, e api.cloudflare.com/dash.cloudflare.com não estão nela — chamadas diretas de lá para a API da Cloudflare são bloqueadas pelo proxy (erro 403 na camada de proxy, não timeout). Isso foi confirmado testando curl e wrangler direto do sandbox. Por isso o deploy roda via um script local (publicar-cloudflare.bat/.command) no computador do usuário, que tem internet normal — o mesmo princípio de ferramentas como Claude Code/opencode rodando wrangler no shell local da máquina do usuário.

Não tente rodar npx wrangler pages deploy direto do bash do sandbox — vai falhar por bloqueio de rede, não por erro de configuração.

## Credenciais

Tudo vem de prospector-config.json (bloco cloudflare): apiToken, accountId. O token vive SÓ nesse arquivo, no computador do usuário — nunca é digitado no chat, nunca é exibido em nenhuma saída, log ou comando mostrado ao usuário. Se estiverem vazios, oriente o usuário: dashboard, aba Configurações, seção Conexão Cloudflare, colar o token e o account ID e salvar (ou editar o arquivo na mão). Nunca pelo chat.

O token precisa da permissão "Cloudflare Pages — Edit" (ou o template "Developer Services", que cobre Pages/Workers/D1/KV/R2 — mais restrito que "Write all resources", que é acesso total e deve ser evitado).

## Pré-requisito de build (Astro)

O site de cada cliente é um projeto Astro estático (skill redesign-premium). O build também roda melhor no ambiente do usuário se npm/node não estiverem disponíveis no sandbox; se estiverem, pode buildar no sandbox e só o deploy final roda local:

```bash
cd sites/[slug] && npm install --silent && npm run build
```

Isso gera sites/[slug]/dist/ — é essa pasta que sobe para o Pages.

## Publicação (via fila + script local)

Primeiro, garanta os arquivos do publicador na pasta conectada (copie de references/ desta skill, sobrescrevendo versões antigas): publicar-cloudflare.bat + publicar-cloudflare.ps1 (Windows) e/ou publicar-cloudflare.command (Mac). Em dúvida, copie os dois — cada sistema ignora o que não usa.

Depois, monte a fila: escreva/atualize fila-publicacao.txt na raiz da pasta conectada, uma linha por site: sites/[slug]/dist|slug. Uma linha por cliente do lote.

Em seguida, peça UM duplo clique no publicar-cloudflare.bat (Windows) ou publicar-cloudflare.command (Mac — se o macOS bloquear por segurança na primeira vez: botão direito, Abrir). O script lê o token do prospector-config.json, publica cada site da fila via npx wrangler pages deploy, e renomeia a fila para fila-publicada-[data].txt ao terminar. Log completo em publicador-log.txt.

O nome do projeto é sempre o slug do cliente. Se o slug tiver caracteres inválidos para subdomínio (acentos, underscore), normalize para minúsculas + hífen antes de usar como slug/nome de projeto.

No primeiro deploy de um cliente, o Wrangler cria o projeto Pages automaticamente se não existir — não precisa de passo separado.

Para redeploy (cliente pediu ajuste, ou saiu do editor visual), adicione a linha de novo na fila e peça outro duplo clique — a URL [slug].pages.dev não muda.

Se o script relatar erro de token inválido/expirado, NÃO tente adivinhar ou pedir o token no chat — oriente o usuário a gerar um novo em dash.cloudflare.com e salvar via dashboard (Configurações, Conexão Cloudflare).

## Domínio customizado (quando o cliente fecha)

Se o usuário já tem um domínio próprio para revender e ele já está na mesma conta Cloudflare (zona DNS gerenciada por ela), oriente a rodar manualmente, no mesmo terminal onde o publicador roda ou via prompt próprio:

```bash
npx wrangler pages project domain add [slug] "[dominio-desejado]" --account-id="[accountId]"
```

Isso é uma ação pontual por domínio — pode orientar o usuário a rodar ela mesma vez que fizer sentido, já que não é parte do fluxo repetitivo de publicação.

## Verificação (obrigatória, após qualquer publicação)

Confira publicador-log.txt — cada site deve aparecer como "OK: [slug] publicado". Abra https://[slug].pages.dev e confirme que carrega com conteúdo certo (HTTPS é automático no Pages, sem passo extra). Atualize leads.md e o dashboard com status publicado e a URL (urlNova = a URL do .pages.dev ou domínio customizado).

## Teste de conexão do /setup

Publique um projeto mínimo ("Funcionou!") como prospector-teste pelo fluxo acima (fila + duplo clique); se der certo, a URL https://prospector-teste.pages.dev confirma token e account ID corretos. Pode apagar o projeto de teste depois rodando npx wrangler pages project delete prospector-teste --account-id="[accountId]" no mesmo terminal local.

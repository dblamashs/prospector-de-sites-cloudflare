---
description: Publica as páginas redesenhadas na Cloudflare (Pages) e retorna as URLs públicas
argument-hint: "[nome do cliente ou todos]"
---

Publique páginas na Cloudflare seguindo a skill deploy-cloudflare.

## Importante: rode este comando na aba Code

A publicação exige rede que alcance a API da Cloudflare. A aba Home do Cowork não tem esse acesso (bloqueio de proxy confirmado); a aba Code tem. Se este comando estiver rodando na Home, avise o usuário e oriente a abrir a aba Code, conectar a mesma pasta do projeto, e repetir o comando lá.

## Passos

Passo 1: Leia prospector-config.json. Se os dados da Cloudflare (apiToken, accountId) não estiverem preenchidos, oriente o usuário a preenchê-los pelo dashboard (aba Configurações, seção Conexão Cloudflare) — nunca colete o token pelo chat. Não prossiga sem eles.

Passo 2: Determine o que publicar: $ARGUMENTS (um cliente ou "todos"), ou liste as páginas com status redesenhado em leads.md e pergunte.

Passo 3: Gere a página-capa de cada cliente — preencha references/capa-proposta-template.html (skill proposta-email) com os dados do lead e a assinatura do config, e salve como sites/[slug]/public/proposta.html. Dentro de public/ do projeto Astro, o build copia o arquivo sem alterar e ele fica acessível em [slug].pages.dev/proposta.html no mesmo deploy.

Passo 4: Builde cada site com npm run build dentro de sites/[slug]/ (confirme que terminou sem erro) — isso gera sites/[slug]/dist/.

Passo 5: Publique seguindo a skill deploy-cloudflare — exporte CLOUDFLARE_API_TOKEN e CLOUDFLARE_ACCOUNT_ID do config, crie o projeto Pages se for o primeiro deploy do cliente (npx --yes wrangler pages project create [slug] --production-branch=main), depois rode npx --yes wrangler pages deploy sites/[slug]/dist --project-name=[slug] --branch=main --commit-dirty=true para cada cliente do lote.

Passo 6: Confira a saída de cada comando de deploy — deve mostrar a URL final ([slug].pages.dev). Se algum falhar, leia o erro e diagnostique (token expirado, build ausente, slug inválido, projeto não existe) antes de seguir.

Passo 7: Verificação — abra https://[slug].pages.dev e https://[slug].pages.dev/proposta.html e confirme que carregam com conteúdo certo e HTTPS válido (automático no Pages).

Passo 8: Atualize leads.md e o banco do dashboard: status publicado mais URL pública nova (urlNova).

## Saída

Liste, por cliente: URL da página nova ([slug].pages.dev) e URL da capa ([slug].pages.dev/proposta.html), ambas confirmadas na saída do deploy/testadas em https. Sugira o próximo passo: /proposta para enviar os e-mails.

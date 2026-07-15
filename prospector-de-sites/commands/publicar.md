---
description: Publica as páginas redesenhadas na Cloudflare (Pages) e retorna as URLs públicas
argument-hint: "[nome do cliente ou todos]"
---

Publique páginas na Cloudflare seguindo a skill deploy-cloudflare.

## Passos

Passo 1: Leia prospector-config.json. Se os dados da Cloudflare (apiToken, accountId) não estiverem preenchidos, oriente o usuário a preenchê-los pelo dashboard (aba Configurações, seção Conexão Cloudflare) — nunca colete o token pelo chat. Não prossiga sem eles.

Passo 2: Determine o que publicar: $ARGUMENTS (um cliente ou "todos"), ou liste as páginas com status redesenhado em leads.md e pergunte.

Passo 3: Gere a página-capa de cada cliente — preencha references/capa-proposta-template.html (skill proposta-email) com os dados do lead e a assinatura do config, e salve como sites/[slug]/public/proposta.html. Dentro de public/ do projeto Astro, o build copia o arquivo sem alterar e ele fica acessível em [slug].pages.dev/proposta.html no mesmo deploy.

Passo 4: Builde cada site com npm run build dentro de sites/[slug]/ (confirme que terminou sem erro) — isso gera sites/[slug]/dist/.

Passo 5: Monte/atualize a fila e peça o duplo clique, seguindo a skill deploy-cloudflare: garanta publicar-cloudflare.bat/.ps1 (Windows) e .command (Mac) copiados na pasta conectada, escreva fila-publicacao.txt com uma linha sites/[slug]/dist|slug por cliente do lote, e peça UM duplo clique no publicar-cloudflare.bat ou .command. O deploy roda no computador do usuário (o sandbox não alcança a API da Cloudflare) — não tente rodar wrangler direto por aqui.

Passo 6: Aguarde a confirmação do usuário ("publiquei" / "rodei o script") e leia publicador-log.txt para confirmar "OK: [slug] publicado" de cada site. Se algum falhar, leia o erro no log e diagnostique (token expirado, build ausente, slug inválido) antes de seguir.

Passo 7: Verificação — abra https://[slug].pages.dev e https://[slug].pages.dev/proposta.html e confirme que carregam com conteúdo certo e HTTPS válido (automático no Pages).

Passo 8: Atualize leads.md e o banco do dashboard: status publicado mais URL pública nova (urlNova).

## Saída

Liste, por cliente: URL da página nova ([slug].pages.dev) e URL da capa ([slug].pages.dev/proposta.html), ambas confirmadas no log/testadas em https. Sugira o próximo passo: /proposta para enviar os e-mails.

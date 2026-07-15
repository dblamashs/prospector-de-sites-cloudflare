---
name: deploy-cloudflare
description: Esta skill deve ser usada ao publicar páginas na Cloudflare — deploy via Wrangler CLI em Cloudflare Pages, um projeto por cliente, criação da URL pública (*.pages.dev) e domínio customizado quando o cliente fecha. Acione quando o usuário disser "publicar", "subir o site", "colocar no ar", "deploy", "cloudflare" ou rodar /publicar ou o teste de conexão do /setup.
---

# Deploy na Cloudflare (Pages)

Publicar cada site como um projeto Cloudflare Pages isolado — https://[slug].pages.dev.

## Importante: isso roda na aba "Code" do Cowork, não na aba "Home"

O ambiente padrão do Cowork (aba Home, onde a maioria das skills roda) tem uma lista de domínios de rede liberados que NÃO inclui api.cloudflare.com/dash.cloudflare.com — chamadas diretas de lá pra API da Cloudflare são bloqueadas. Já a aba "Code" do Cowork tem rede irrestrita e alcança a API da Cloudflare normalmente (confirmado testando curl e um deploy real via wrangler).

Por isso: prospecção e redesign de sites podem rodar na Home, mas a publicação (/publicar) precisa ser feita com o usuário atuando na aba Code, com a pasta do projeto conectada lá. Se o agente estiver rodando na aba Home e for pedido pra publicar, oriente o usuário a abrir a aba Code, conectar a mesma pasta (Site_Prospect ou como for chamada), e repetir o pedido lá.

## Credenciais

Tudo vem de prospector-config.json (bloco cloudflare): apiToken, accountId. O token vive SÓ nesse arquivo — nunca é digitado no chat, nunca é exibido em nenhuma saída, log ou comando mostrado ao usuário. Se estiverem vazios, oriente o usuário: dashboard, aba Configurações, seção Conexão Cloudflare, colar o token e o account ID e salvar (ou editar o arquivo na mão). Nunca pelo chat.

O token precisa da permissão "Cloudflare Pages — Edit" (ou o template "Developer Services", que cobre Pages/Workers/D1/KV/R2 — mais restrito que "Write all resources", que é acesso total e deve ser evitado).

## Pré-requisito de build (Astro)

O site de cada cliente é um projeto Astro estático (skill redesign-premium). Antes de publicar:

```bash
cd sites/[slug] && npm install --silent && npm run build
```

Isso gera sites/[slug]/dist/ — é essa pasta que sobe para o Pages.

## Publicação (direta, via Code)

Leia prospector-config.json e exporte as credenciais como variáveis de ambiente antes de qualquer comando wrangler:

```bash
export CLOUDFLARE_API_TOKEN="<apiToken do config>"
export CLOUDFLARE_ACCOUNT_ID="<accountId do config>"
```

Nunca imprima essas variáveis no chat depois de exportadas.

Se for o primeiro deploy desse cliente, crie o projeto Pages antes:

```bash
npx --yes wrangler pages project create [slug] --production-branch=main
```

Depois publique:

```bash
npx --yes wrangler pages deploy sites/[slug]/dist --project-name=[slug] --branch=main --commit-dirty=true
```

O nome do projeto é sempre o slug do cliente. Se o slug tiver caracteres inválidos para subdomínio (acentos, underscore), normalize para minúsculas + hífen antes de usar como slug/nome de projeto.

Para redeploy (cliente pediu ajuste, ou saiu do editor visual), rode só o comando de deploy de novo — não precisa recriar o projeto. A URL [slug].pages.dev não muda.

Se o comando relatar erro de token inválido/expirado, NÃO tente adivinhar ou pedir o token no chat — oriente o usuário a gerar um novo em dash.cloudflare.com e salvar via dashboard (Configurações, Conexão Cloudflare).

## Domínio customizado (quando o cliente fecha)

Se o usuário já tem um domínio próprio para revender e ele já está na mesma conta Cloudflare (zona DNS gerenciada por ela):

```bash
npx wrangler pages project domain add [slug] "[dominio-desejado]" --account-id="[accountId]"
```

Isso é uma ação pontual por domínio — pode orientar o usuário a rodar ela mesma vez que fizer sentido, já que não é parte do fluxo repetitivo de publicação.

## Verificação (obrigatória, após qualquer publicação)

Confira a saída do comando de deploy — deve mostrar a URL final. Abra https://[slug].pages.dev e confirme que carrega com conteúdo certo (HTTPS é automático no Pages, sem passo extra). Atualize leads.md e o dashboard com status publicado e a URL (urlNova = a URL do .pages.dev ou domínio customizado).

## Teste de conexão do /setup

Publique um projeto mínimo ("Funcionou!") como prospector-teste pelo fluxo acima; se der certo, a URL https://prospector-teste.pages.dev confirma token e account ID corretos. Pode apagar o projeto de teste depois rodando npx wrangler pages project delete prospector-teste --account-id="[accountId]".

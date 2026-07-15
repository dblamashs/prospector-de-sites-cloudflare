#!/bin/bash
cd "$(dirname "$0")"

CONFIG="prospector-config.json"
FILA="fila-publicacao.txt"
LOG="publicador-log.txt"

log() {
echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG"
}

if [ ! -f "$CONFIG" ]; then
echo "prospector-config.json nao encontrado nesta pasta."
read -p "Pressione Enter para sair"
exit 1
fi

API_TOKEN=$(python3 -c "import json;print(json.load(open('$CONFIG')).get('cloudflare',{}).get('apiToken',''))")
ACCOUNT_ID=$(python3 -c "import json;print(json.load(open('$CONFIG')).get('cloudflare',{}).get('accountId',''))")

if [ -z "$API_TOKEN" ] || [ -z "$ACCOUNT_ID" ]; then
echo "Faltam apiToken ou accountId em prospector-config.json (bloco cloudflare)."
echo "Preencha pelo dashboard: Configuracoes > Conexao Cloudflare."
read -p "Pressione Enter para sair"
exit 1
fi

if [ ! -f "$FILA" ]; then
echo "Nenhuma fila-publicacao.txt encontrada. Nada para publicar."
read -p "Pressione Enter para sair"
exit 0
fi

export CLOUDFLARE_API_TOKEN="$API_TOKEN"

PUBLICADOS=()
FALHAS=()

log "Iniciando publicacao..."
while IFS='|' read -r DIST SLUG; do
[ -z "$DIST" ] && continue
DIST=$(echo "$DIST" | sed 's/^ *//;s/ *$//')
SLUG=$(echo "$SLUG" | sed 's/^ *//;s/ *$//')

if [ ! -d "$DIST" ]; then
log "PULADO: pasta '$DIST' nao existe (slug: $SLUG)."
FALHAS+=("$SLUG")
continue
fi

log "Publicando '$SLUG' a partir de '$DIST'..."
npx --yes wrangler pages deploy "$DIST" --project-name="$SLUG" --account-id="$ACCOUNT_ID" --branch=main --commit-dirty=true >> "$LOG" 2>&1

if [ $? -eq 0 ]; then
log "OK: $SLUG publicado em https://$SLUG.pages.dev"
PUBLICADOS+=("$SLUG")
else
log "ERRO ao publicar $SLUG (veja detalhes no log)."
FALHAS+=("$SLUG")
fi
done < "$FILA"

mv "$FILA" "fila-publicada-$(date '+%Y-%m-%d_%H%M%S').txt"

echo ""
echo "===================================="
echo "Publicados: ${PUBLICADOS[*]}"
if [ ${#FALHAS[@]} -gt 0 ]; then
echo "Falharam: ${FALHAS[*]} -- veja publicador-log.txt"
fi
echo "===================================="
read -p "Pressione Enter para fechar"

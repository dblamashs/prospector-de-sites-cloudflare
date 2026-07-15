param()
$ErrorActionPreference = "Continue"
$Pasta = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $Pasta

$ConfigPath = Join-Path $Pasta "prospector-config.json"
$FilaPath = Join-Path $Pasta "fila-publicacao.txt"
$LogPath = Join-Path $Pasta "publicador-log.txt"

function Log($msg) {
    $linha = "[{0}] {1}" -f (Get-Date -Format "yyyy-MM-dd HH:mm:ss"), $msg
        Add-Content -Path $LogPath -Value $linha
            Write-Host $linha
            }

            try {

            if (-not (Test-Path $ConfigPath)) {
                Write-Host "prospector-config.json nao encontrado em $Pasta"
                    Read-Host "Pressione Enter para sair"
                        exit 1
                        }

                        $cfg = Get-Content $ConfigPath -Raw | ConvertFrom-Json
                        $apiToken = $cfg.cloudflare.apiToken
                        $accountId = $cfg.cloudflare.accountId

                        if ([string]::IsNullOrWhiteSpace($apiToken) -or [string]::IsNullOrWhiteSpace($accountId)) {
                            Write-Host "Faltam apiToken ou accountId em prospector-config.json (bloco cloudflare)."
                                Write-Host "Preencha pelo dashboard: Configuracoes > Conexao Cloudflare."
                                    Read-Host "Pressione Enter para sair"
                                        exit 1
                                        }

                                        if (-not (Test-Path $FilaPath)) {
                                            Write-Host "Nenhuma fila-publicacao.txt encontrada. Nada para publicar."
                                                Read-Host "Pressione Enter para sair"
                                                    exit 0
                                                    }

                                                    $env:CLOUDFLARE_API_TOKEN = $apiToken

                                                    $linhas = Get-Content $FilaPath | Where-Object { $_.Trim() -ne "" }
                                                    if ($linhas.Count -eq 0) {
                                                        Write-Host "Fila vazia."
                                                            Read-Host "Pressione Enter para sair"
                                                                exit 0
                                                                }

                                                                Log "Iniciando publicacao de $($linhas.Count) site(s)."
                                                                $publicados = @()
                                                                $falhas = @()

                                                                foreach ($linha in $linhas) {
                                                                    $partes = $linha.Split("|")
                                                                        $distPath = $partes[0].Trim()
                                                                            $slug = $partes[1].Trim()

                                                                                if (-not (Test-Path $distPath)) {
                                                                                        Log "PULADO: pasta '$distPath' nao existe (slug: $slug)."
                                                                                                $falhas += $slug
                                                                                                        continue
                                                                                                            }
                                                                                                            
                                                                                                                Log "Publicando '$slug' a partir de '$distPath'..."
                                                                                                                    $saida = cmd /c "npx --yes wrangler pages deploy `"$distPath`" --project-name=$slug --account-id=$accountId --branch=main --commit-dirty=true 2>&1"
                                                                                                                        $exitCode = $LASTEXITCODE
                                                                                                                            $saida | Out-String | Add-Content -Path $LogPath
                                                                                                                            
                                                                                                                                if ($exitCode -eq 0) {
                                                                                                                                        Log "OK: $slug publicado em https://$slug.pages.dev"
                                                                                                                                                $publicados += $slug
                                                                                                                                                    } else {
                                                                                                                                                            Log "ERRO ao publicar $slug (veja detalhes acima no log)."
                                                                                                                                                                    $falhas += $slug
                                                                                                                                                                        }
                                                                                                                                                                        }
                                                                                                                                                                        
                                                                                                                                                                        $dataArquivada = Get-Date -Format "yyyy-MM-dd_HHmmss"
                                                                                                                                                                        Move-Item -Path $FilaPath -Destination (Join-Path $Pasta "fila-publicada-$dataArquivada.txt") -Force
                                                                                                                                                                        
                                                                                                                                                                        Write-Host ""
                                                                                                                                                                        Write-Host "===================================="
                                                                                                                                                                        Write-Host "Publicados: $($publicados -join ', ')"
                                                                                                                                                                        if ($falhas.Count -gt 0) {
                                                                                                                                                                            Write-Host "Falharam: $($falhas -join ', ') -- veja publicador-log.txt"
                                                                                                                                                                            }
                                                                                                                                                                            Write-Host "===================================="
                                                                                                                                                                            Read-Host "Pressione Enter para fechar"
                                                                                                                                                                            
                                                                                                                                                                            } catch {
                                                                                                                                                                                Write-Host ""
                                                                                                                                                                                    Write-Host "ERRO INESPERADO: $_"
                                                                                                                                                                                        Add-Content -Path $LogPath -Value "ERRO INESPERADO: $_"
                                                                                                                                                                                            Read-Host "Pressione Enter para fechar"
                                                                                                                                                                                            }
                                                                                                                                                                                            

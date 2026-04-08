# Certificadora MV — Gerenciamento de Certificados Digitais

Sistema de controle de vencimentos e notificação por e-mail de certificados digitais.

## Estrutura do Repositório

```
certificadora-mv/
├── main.py              # Aplicação FastHTML (código principal)
├── requirements.txt     # Dependências Python
├── Dockerfile           # Container para Cloud Run
├── .dockerignore        # Arquivos ignorados no build Docker
├── .gitignore           # Arquivos ignorados no Git
├── .env.example         # Modelo de variáveis de ambiente
└── README.md            # Este arquivo
```

## Deploy no Google Cloud Run

### Pré-requisitos

1. Conta no Google Cloud com billing ativo
2. [Google Cloud CLI (gcloud)](https://cloud.google.com/sdk/docs/install) instalado
3. Repositório no GitHub (ou Git local)

### Passo 1 — Criar repositório no GitHub

```bash
# Na pasta do projeto
cd certificadora-mv
git init
git add .
git commit -m "feat: versão inicial certificadora MV"

# Crie o repositório no GitHub (https://github.com/new)
# Depois conecte:
git remote add origin https://github.com/SEU_USUARIO/certificadora-mv.git
git branch -M main
git push -u origin main
```

### Passo 2 — Configurar Google Cloud

```bash
# Login no Google Cloud
gcloud auth login

# Criar projeto (ou usar existente)
gcloud projects create certificadora-mv --name="Certificadora MV"
gcloud config set project certificadora-mv

# Ativar APIs necessárias
gcloud services enable cloudbuild.googleapis.com
gcloud services enable run.googleapis.com
gcloud services enable artifactregistry.googleapis.com
```

### Passo 3 — Deploy no Cloud Run

```bash
# Deploy direto do código fonte (o Cloud Build faz o build do Docker)
gcloud run deploy certificadora-mv \
  --source . \
  --region southamerica-east1 \
  --allow-unauthenticated \
  --port 8080 \
  --memory 512Mi \
  --cpu 1 \
  --min-instances 0 \
  --max-instances 3 \
  --set-env-vars "LOGIN_USER=mvtec2026" \
  --set-env-vars "LOGIN_PASSWORD=MV@@2026" \
  --set-env-vars "SMTP_SERVER=smtp.gmail.com" \
  --set-env-vars "SMTP_PORT=587" \
  --set-env-vars "EMAIL_USER=certificadosmvcontabilidade@gmail.com" \
  --set-env-vars "EMAIL_PASSWORD=zrfs pbqm urcr viyx" \
  --set-env-vars "USE_TLS=True" \
  --set-env-vars "SESSION_SECRET=sua-chave-secreta-segura-aqui"
```

> **Região `southamerica-east1`** = São Paulo, a mais próxima do Brasil.

Após o deploy, o Cloud Run retorna a URL da aplicação (ex: `https://certificadora-mv-xxxx-rj.a.run.app`).

### Passo 4 — Domínio personalizado (opcional)

```bash
# Mapear domínio customizado
gcloud run domain-mappings create \
  --service certificadora-mv \
  --domain certificados.mvcontabilidade.com.br \
  --region southamerica-east1
```

## Variáveis de Ambiente

| Variável | Descrição | Padrão |
|---|---|---|
| `LOGIN_USER` | Usuário de acesso | `admin` |
| `LOGIN_PASSWORD` | Senha de acesso | `changeme` |
| `SESSION_SECRET` | Chave de sessão (gere uma aleatória) | auto-gerado |
| `SMTP_SERVER` | Servidor SMTP | `smtp.gmail.com` |
| `SMTP_PORT` | Porta SMTP | `587` |
| `EMAIL_USER` | E-mail remetente | — |
| `EMAIL_PASSWORD` | Senha de app do e-mail | — |
| `USE_TLS` | Usar TLS | `True` |
| `PORT` | Porta da aplicação | `8080` |

## Atualizar após mudanças

```bash
# Faça as alterações no código, depois:
git add .
git commit -m "fix: descrição da alteração"
git push

# Redeploy
gcloud run deploy certificadora-mv --source . --region southamerica-east1
```

## Custos estimados (Cloud Run)

- **Free tier**: 2 milhões de requests/mês + 360.000 GB-segundos grátis
- Para uso interno (poucos acessos), provavelmente **custo zero** ou muito próximo disso
- `min-instances 0` garante que não há custo quando ninguém está usando

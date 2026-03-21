# ci-infra-local

Repositório centralizado para subir runners self-hosted do GitHub Actions localmente.

## Estrutura do projeto

Na raiz:

- docker-compose.yml (compartilhado por todos os serviços)
- Dockerfile (compartilhado por todos os serviços)
- start.sh (inicialização do runner)
- services.template.yml (template versionado, sem credenciais reais)
- services.yml (arquivo local com credenciais, ignorado no Git)
- manage_services.py (loader com classe e comandos de orquestração)
- setup.ps1 (setup interativo no Windows)
- setup.sh (setup interativo no Linux/Mac)

Observacao: setup.sh e setup.ps1 sao mantidos por compatibilidade. O fluxo oficial e via manage_services.py.

Pastas de serviço existentes:

- identity-users
- livros-service
- ms-pedidos
- notification-service
- payment-service

## Pré-requisitos

- Docker Desktop ativo
- Docker Compose instalado
- Python 3.9+
- Dependências Python: pip install -r requirements.txt

## Uso rápido (recomendado)

Windows (PowerShell), Linux e Mac:

1. Inicialize o arquivo local: python manage_services.py init
2. Edite services.yml e preencha os valores reais
3. Valide a configuracao: python manage_services.py validate
4. Suba um servico: python manage_services.py up ms-pedidos

## Arquivo de configuração (YAML)

O arquivo services.template.yml é o único que deve ser versionado.
O arquivo services.yml é local e contém credenciais reais.

Exemplo de estrutura:

```yaml
services:
  - name: ms-pedidos
    repo_url: https://github.com/SEU_ORG/ms-pedidos
    runner_token: SEU_TOKEN_AQUI
```

## Comandos

Inicializar arquivo local:

- python manage_services.py init

Listar serviços configurados:

- python manage_services.py list

Subir um serviço:

- python manage_services.py up ms-pedidos

Subir todos os serviços:

- python manage_services.py up-all

Parar um serviço:

- python manage_services.py down ms-pedidos

Ver logs:

- python manage_services.py logs ms-pedidos

Ver logs de todos os servicos:

- python manage_services.py logs-all

Status de todos os servicos:

- python manage_services.py status

Validar pre-requisitos e placeholders:

- python manage_services.py validate

Executar sem aplicar alteracoes (dry-run):

- python manage_services.py --dry-run up ms-pedidos

## Mecanismo de trava para credenciais

- services.template.yml usa apenas placeholders
- services.yml é ignorado via .gitignore
- .generated/ (arquivos .env temporários gerados no runtime) também é ignorado

## Segurança

- Nunca coloque token real em services.template.yml
- Não compartilhe token por chat ou commit
- Se houver vazamento, gere um novo token
- Verifique regularmente se nao existe token real no repositorio (git grep)

## Troubleshooting

- Erro "Docker nao encontrado": inicie o Docker Desktop e valide com docker --version.
- Erro "services.yml nao encontrado": rode python manage_services.py init.
- Erro de placeholder em token/repo: atualize repo_url e runner_token em services.yml.
- Container reinicia continuamente: rode python manage_services.py logs <servico> e confira token/URL.
- Jobs com Docker falhando: confirme se /var/run/docker.sock esta disponivel no host.

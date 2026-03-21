# ci-infra-local

Repositório centralizado para subir runners self-hosted do GitHub Actions localmente.
Cada pasta de serviço contém sua própria configuração de container.

## Estrutura do projeto

Serviços disponíveis:

- identity-users
- livros-service
- ms-pedidos
- notification-service
- payment-service

Cada serviço possui os arquivos:

- .env.example (template versionado)
- .env (arquivo local com credenciais, não versionado)
- docker-compose.yml
- Dockerfile

Na raiz:

- setup.ps1 (setup interativo no Windows)
- setup.sh (setup interativo no Linux/Mac)

## Pré-requisitos

- Docker e Docker Compose instalados
- Acesso aos repositórios no GitHub
- Token de runner self-hosted (expira em 1 hora)

## Uso rápido (recomendado)

Windows (PowerShell):

1. Execute: .\setup.ps1
2. Informe REPO_URL e RUNNER_TOKEN para cada serviço
3. Suba o serviço desejado com docker compose up -d

Linux/Mac:

1. Execute: bash setup.sh
2. Informe REPO_URL e RUNNER_TOKEN para cada serviço
3. Suba o serviço desejado com docker compose up -d

## Subir um serviço manualmente

Exemplo com identity-users:

1. Entre na pasta do serviço
2. Crie .env a partir do .env.example
3. Preencha REPO_URL e RUNNER_TOKEN
4. Execute docker compose up -d

## Como gerar RUNNER_TOKEN

1. Abra o repositório no GitHub
2. Acesse: Settings > Actions > Runners > New self-hosted runner
3. Copie o token exibido
4. Use o token imediatamente (validade de 1 hora)

## Variáveis de ambiente

- REPO_URL: URL do repositório GitHub (exemplo: https://github.com/org/repo)
- RUNNER_TOKEN: token temporário para registrar o runner

## Segurança

- Arquivos .env são ignorados pelo .gitignore
- Apenas .env.example é versionado
- Não compartilhe token por chat ou commit
- Se houver vazamento, gere um novo token

## Comandos úteis

Subir um serviço:

docker compose up -d

Ver logs:

docker compose logs -f

Parar e remover:

docker compose down

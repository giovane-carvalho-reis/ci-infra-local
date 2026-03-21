#!/usr/bin/env python3
from __future__ import annotations

import argparse
import shutil
import subprocess
import sys
from dataclasses import dataclass
from pathlib import Path
from typing import Iterable, List

import yaml


ROOT_DIR = Path(__file__).resolve().parent
CONFIG_TEMPLATE = ROOT_DIR / "services.template.yml"
CONFIG_FILE = ROOT_DIR / "services.yml"
GENERATED_DIR = ROOT_DIR / ".generated"


@dataclass
class ServiceConfig:
    name: str
    repo_url: str
    runner_token: str

    def validate(self) -> None:
        if not self.name.strip():
            raise ValueError("service.name vazio")
        if not self.repo_url.strip():
            raise ValueError(f"repo_url vazio para {self.name}")
        if not self.runner_token.strip():
            raise ValueError(f"runner_token vazio para {self.name}")


class ServiceConfigLoader:
    def __init__(self, config_path: Path) -> None:
        self.config_path = config_path

    def load(self) -> List[ServiceConfig]:
        if not self.config_path.exists():
            raise FileNotFoundError(
                f"Arquivo {self.config_path.name} nao encontrado. "
                "Execute: python manage_services.py init"
            )

        raw = yaml.safe_load(self.config_path.read_text(encoding="utf-8")) or {}
        services = raw.get("services", [])
        if not isinstance(services, list) or not services:
            raise ValueError("services.yml invalido: 'services' deve ser uma lista nao vazia")

        items: List[ServiceConfig] = []
        for row in services:
            if not isinstance(row, dict):
                raise ValueError("services.yml invalido: cada item em 'services' deve ser um objeto")
            item = ServiceConfig(
                name=str(row.get("name", "")).strip(),
                repo_url=str(row.get("repo_url", "")).strip(),
                runner_token=str(row.get("runner_token", "")).strip(),
            )
            item.validate()
            items.append(item)
        return items


def ensure_prerequisites() -> None:
    required_commands = [
        (["docker", "--version"], "Docker nao encontrado. Instale e inicie o Docker Desktop."),
        (
            ["docker", "compose", "version"],
            "Docker Compose nao encontrado. Atualize o Docker Desktop para incluir o plugin compose.",
        ),
    ]
    for cmd, message in required_commands:
        if shutil.which(cmd[0]) is None:
            raise ValueError(message)
        result = subprocess.run(cmd, cwd=str(ROOT_DIR), capture_output=True, text=True)
        if result.returncode != 0:
            raise ValueError(f"{message} Detalhes: {result.stderr.strip() or result.stdout.strip()}")


def ensure_local_config() -> None:
    if CONFIG_FILE.exists():
        print("services.yml ja existe.")
        return
    CONFIG_FILE.write_text(CONFIG_TEMPLATE.read_text(encoding="utf-8"), encoding="utf-8")
    print("services.yml criado a partir de services.template.yml")
    print("Preencha repo_url e runner_token antes de executar up/up-all.")


def get_service(items: Iterable[ServiceConfig], name: str) -> ServiceConfig:
    for item in items:
        if item.name == name:
            return item
    raise ValueError(f"Servico '{name}' nao encontrado no services.yml")


def write_env_file(service: ServiceConfig) -> Path:
    GENERATED_DIR.mkdir(exist_ok=True)
    env_file = GENERATED_DIR / f"{service.name}.env"
    content = (
        f"SERVICE_NAME={service.name}\n"
        f"REPO_URL={service.repo_url}\n"
        f"RUNNER_TOKEN={service.runner_token}\n"
    )
    env_file.write_text(content, encoding="utf-8")
    return env_file


def remove_env_file(service: ServiceConfig) -> None:
    env_file = GENERATED_DIR / f"{service.name}.env"
    if env_file.exists():
        env_file.unlink()


def run_compose(service: ServiceConfig, compose_args: List[str], dry_run: bool = False) -> int:
    env_file = write_env_file(service)
    cmd = ["docker", "compose", "--env-file", str(env_file), *compose_args]
    print(f"[{service.name}] Executando: {' '.join(cmd)}")
    if dry_run:
        return 0
    return subprocess.call(cmd, cwd=str(ROOT_DIR))


def validate_no_placeholders(items: Iterable[ServiceConfig]) -> None:
    for item in items:
        if item.runner_token == "SEU_TOKEN_AQUI":
            raise ValueError(
                f"runner_token ainda com placeholder para '{item.name}'. "
                "Atualize o services.yml local."
            )
        if "SEU_ORG" in item.repo_url:
            raise ValueError(
                f"repo_url ainda com placeholder para '{item.name}'. "
                "Atualize o services.yml local."
            )


def cmd_list(items: List[ServiceConfig]) -> int:
    print("Servicos configurados:")
    for item in items:
        print(f"- {item.name} -> {item.repo_url}")
    return 0


def cmd_up(items: List[ServiceConfig], service_name: str, dry_run: bool = False) -> int:
    validate_no_placeholders(items)
    service = get_service(items, service_name)
    return run_compose(service, ["up", "-d"], dry_run=dry_run)


def cmd_down(items: List[ServiceConfig], service_name: str, dry_run: bool = False) -> int:
    service = get_service(items, service_name)
    code = run_compose(service, ["down"], dry_run=dry_run)
    if code == 0 and not dry_run:
        remove_env_file(service)
    return code


def cmd_logs(items: List[ServiceConfig], service_name: str, follow: bool = True, dry_run: bool = False) -> int:
    service = get_service(items, service_name)
    args = ["logs"]
    if follow:
        args.append("-f")
    return run_compose(service, args, dry_run=dry_run)


def cmd_up_all(items: List[ServiceConfig], dry_run: bool = False) -> int:
    validate_no_placeholders(items)
    for item in items:
        code = run_compose(item, ["up", "-d"], dry_run=dry_run)
        if code != 0:
            return code
    return 0


def cmd_logs_all(items: List[ServiceConfig], follow: bool = False, dry_run: bool = False) -> int:
    for item in items:
        code = cmd_logs(items, item.name, follow=follow, dry_run=dry_run)
        if code != 0:
            return code
    return 0


def cmd_status(items: List[ServiceConfig], dry_run: bool = False) -> int:
    for item in items:
        code = run_compose(item, ["ps"], dry_run=dry_run)
        if code != 0:
            return code
    return 0


def cmd_validate(items: List[ServiceConfig]) -> int:
    ensure_prerequisites()
    validate_no_placeholders(items)
    print("Configuracao valida: pre-requisitos OK e sem placeholders.")
    return 0


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description="Gerencia runners via services.yml")
    parser.add_argument("--dry-run", action="store_true", help="Mostra os comandos sem executa-los")
    sub = parser.add_subparsers(dest="command", required=True)

    sub.add_parser("init", help="Cria services.yml local a partir do template")
    sub.add_parser("list", help="Lista servicos do services.yml")

    p_up = sub.add_parser("up", help="Sobe um servico")
    p_up.add_argument("service")

    p_down = sub.add_parser("down", help="Para um servico")
    p_down.add_argument("service")

    p_logs = sub.add_parser("logs", help="Exibe logs de um servico")
    p_logs.add_argument("service")
    p_logs.add_argument("--no-follow", action="store_true", help="Exibe logs sem ficar seguindo")

    sub.add_parser("up-all", help="Sobe todos os servicos")
    p_logs_all = sub.add_parser("logs-all", help="Exibe logs de todos os servicos")
    p_logs_all.add_argument("--follow", action="store_true", help="Segue logs de todos os servicos")
    sub.add_parser("status", help="Exibe status de containers de todos os servicos")
    sub.add_parser("validate", help="Valida pre-requisitos e placeholders de configuracao")

    return parser


def main() -> int:
    parser = build_parser()
    args = parser.parse_args()

    try:
        if args.command == "init":
            ensure_local_config()
            return 0

        ensure_prerequisites()
        loader = ServiceConfigLoader(CONFIG_FILE)
        items = loader.load()

        if args.command == "list":
            return cmd_list(items)
        if args.command == "validate":
            return cmd_validate(items)
        if args.command == "up":
            return cmd_up(items, args.service, dry_run=args.dry_run)
        if args.command == "down":
            return cmd_down(items, args.service, dry_run=args.dry_run)
        if args.command == "logs":
            return cmd_logs(items, args.service, follow=not args.no_follow, dry_run=args.dry_run)
        if args.command == "up-all":
            return cmd_up_all(items, dry_run=args.dry_run)
        if args.command == "logs-all":
            return cmd_logs_all(items, follow=args.follow, dry_run=args.dry_run)
        if args.command == "status":
            return cmd_status(items, dry_run=args.dry_run)

        parser.print_help()
        return 1
    except (FileNotFoundError, ValueError) as exc:
        print(f"Erro: {exc}")
        return 2


if __name__ == "__main__":
    sys.exit(main())

#!/bin/bash
# Ajusta permissões para runner GitHub acessar Docker
# Execute como root ou com sudo

# 1. Adiciona o usuário runner ao grupo docker
usermod -aG docker runner

# 2. Ajusta permissões do socket Docker
chown root:docker /var/run/docker.sock
chmod 660 /var/run/docker.sock

# 3. Mostra grupos do runner e permissões do socket
id runner
groups runner
ls -l /var/run/docker.sock

echo "Faça logout/login do usuário runner para aplicar o grupo se necessário."
echo "Pronto! O runner deve conseguir acessar o Docker sem erro de permissão."

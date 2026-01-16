#!/bin/bash

# Bootstrap script para dotfiles
# Uso: curl -fsSL https://raw.githubusercontent.com/pabloreina97/dotfiles/main/bootstrap.sh | bash

set -e

REPO_URL="https://github.com/pabloreina97/dotfiles.git"
DOTFILES_DIR="$HOME/projects/dotfiles"

echo ""
echo "==================================="
echo "  Bootstrap Dotfiles Ubuntu"
echo "==================================="
echo ""

# Instalar git si no existe
if ! command -v git &> /dev/null; then
    echo ">> Instalando git..."
    sudo apt update
    sudo apt install -y git
fi

# Crear directorio projects
mkdir -p "$HOME/projects"

# Clonar repositorio
if [ -d "$DOTFILES_DIR" ]; then
    echo ">> Repositorio ya existe, actualizando..."
    cd "$DOTFILES_DIR"
    git pull
else
    echo ">> Clonando repositorio..."
    git clone "$REPO_URL" "$DOTFILES_DIR"
fi

# Ejecutar setup
cd "$DOTFILES_DIR"
echo ""
echo ">> Ejecutando setup..."
echo ""
./scripts/setup.sh

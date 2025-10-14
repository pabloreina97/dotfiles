#!/bin/bash

# Script de instalación de dotfiles
# Crea symlinks desde el repositorio a los archivos de configuración del sistema

set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Directorio del repositorio dotfiles
DOTFILES_DIR="$HOME/projects/dotfiles"

echo -e "${GREEN}=====================================${NC}"
echo -e "${GREEN}  Instalación de Dotfiles${NC}"
echo -e "${GREEN}=====================================${NC}"
echo ""

# Función para crear backup si el archivo existe
backup_if_exists() {
    if [ -f "$1" ] || [ -L "$1" ]; then
        echo -e "${YELLOW}Creando backup de $1${NC}"
        mv "$1" "$1.backup.$(date +%Y%m%d_%H%M%S)"
    fi
}

# Función para crear symlink
create_symlink() {
    local source="$1"
    local target="$2"

    if [ -e "$source" ]; then
        backup_if_exists "$target"
        ln -sf "$source" "$target"
        echo -e "${GREEN}✓${NC} Linked: $target -> $source"
    else
        echo -e "${RED}✗${NC} No encontrado: $source"
    fi
}

echo -e "${YELLOW}1. Creando symlinks para configuración de Shell...${NC}"
create_symlink "$DOTFILES_DIR/shell/.zshrc" "$HOME/.zshrc"
create_symlink "$DOTFILES_DIR/shell/.bashrc" "$HOME/.bashrc"
create_symlink "$DOTFILES_DIR/shell/.p10k.zsh" "$HOME/.p10k.zsh"

echo ""
echo -e "${YELLOW}2. Creando symlinks para configuración de Git...${NC}"
create_symlink "$DOTFILES_DIR/git/.gitconfig" "$HOME/.gitconfig"

echo ""
echo -e "${YELLOW}3. Configuración de VSCode...${NC}"
echo -e "VSCode se sincroniza con Settings Sync (GitHub). No se crean symlinks."
echo -e "Para activar: Ctrl+Shift+P -> 'Settings Sync: Turn On'"

echo ""
echo -e "${YELLOW}4. Creando symlinks para otras configuraciones...${NC}"
# GitHub CLI
if [ -d "$DOTFILES_DIR/config/gh" ]; then
    backup_if_exists "$HOME/.config/gh"
    ln -sf "$DOTFILES_DIR/config/gh" "$HOME/.config/gh"
    echo -e "${GREEN}✓${NC} Linked: ~/.config/gh -> $DOTFILES_DIR/config/gh"
fi

# Claude Code
mkdir -p "$HOME/.claude"
create_symlink "$DOTFILES_DIR/claude/settings.json" "$HOME/.claude/settings.json"

echo ""
echo -e "${GREEN}=====================================${NC}"
echo -e "${GREEN}  Instalación completada!${NC}"
echo -e "${GREEN}=====================================${NC}"
echo ""
echo -e "Nota: Los archivos originales fueron respaldados con extensión .backup"
echo ""
echo -e "${YELLOW}Si aún no has instalado los paquetes, hazlo ahora:${NC}"
echo -e "  1. Instalar paquetes:  ${YELLOW}./scripts/setup-packages.sh${NC}"
echo -e "  2. Configurar GNOME:   ${YELLOW}./scripts/setup-gnome.sh${NC}"
echo ""
echo -e "${GREEN}Si ya ejecutaste setup-packages.sh antes, ¡todo listo!${NC}"
echo -e "El .zshrc personalizado ha reemplazado el de Oh My Zsh."
echo ""

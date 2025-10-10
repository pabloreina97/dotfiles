#!/bin/bash

# Script para exportar la configuración actual de GNOME
# Ejecutar cuando hagas cambios en GNOME que quieras guardar

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

DOTFILES_DIR="$HOME/projects/dotfiles"

echo -e "${GREEN}=====================================${NC}"
echo -e "${GREEN}  Exportar Configuración de GNOME${NC}"
echo -e "${GREEN}=====================================${NC}"
echo ""

# Crear directorio si no existe
mkdir -p "$DOTFILES_DIR/gnome"

# Exportar configuración de Dash to Panel
echo -e "${YELLOW}Exportando Dash to Panel...${NC}"
dconf dump /org/gnome/shell/extensions/dash-to-panel/ > "$DOTFILES_DIR/gnome/dash-to-panel.conf"

# Exportar configuración de GNOME Shell (extensiones, etc.)
echo -e "${YELLOW}Exportando GNOME Shell...${NC}"
dconf dump /org/gnome/shell/ > "$DOTFILES_DIR/gnome/gnome-shell.conf"

# Exportar configuración de GNOME Desktop (temas, wallpapers, etc.)
echo -e "${YELLOW}Exportando GNOME Desktop...${NC}"
dconf dump /org/gnome/desktop/ > "$DOTFILES_DIR/gnome/gnome-desktop.conf"

# Exportar lista de extensiones instaladas
echo -e "${YELLOW}Exportando lista de extensiones...${NC}"
gnome-extensions list > "$DOTFILES_DIR/gnome/extensions-list.txt"

echo ""
echo -e "${GREEN}Configuración exportada exitosamente!${NC}"
echo ""
echo "Archivos guardados en: $DOTFILES_DIR/gnome/"
echo ""
echo "No olvides hacer commit de los cambios:"
echo -e "  ${YELLOW}cd $DOTFILES_DIR${NC}"
echo -e "  ${YELLOW}git add gnome/${NC}"
echo -e "  ${YELLOW}git commit -m \"Actualizar configuración de GNOME\"${NC}"
echo -e "  ${YELLOW}git push${NC}"
echo ""

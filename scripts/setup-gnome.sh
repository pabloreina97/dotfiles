#!/bin/bash

# Script para instalar y configurar extensiones de GNOME
# Ejecutar después de setup-packages.sh

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

DOTFILES_DIR="$HOME/projects/dotfiles"

echo -e "${GREEN}=====================================${NC}"
echo -e "${GREEN}  Configuración de GNOME${NC}"
echo -e "${GREEN}=====================================${NC}"
echo ""

# Instalar gnome-shell-extension-manager si no está instalado
echo -e "${YELLOW}Verificando herramientas de GNOME...${NC}"
if ! command -v gnome-extensions &> /dev/null; then
    echo "gnome-shell-extensions no encontrado, instalando..."
    sudo apt install -y gnome-shell-extensions gnome-shell-extension-prefs
fi

# Instalar Extension Manager (interfaz gráfica para gestionar extensiones)
if ! flatpak list | grep -q "com.mattjakeman.ExtensionManager"; then
    echo ""
    echo -e "${YELLOW}Instalando Extension Manager...${NC}"
    flatpak install -y flathub com.mattjakeman.ExtensionManager
fi

# Instalar extensiones desde la lista
echo ""
echo -e "${YELLOW}Instalando extensiones de GNOME...${NC}"

# Dash to Panel
if ! gnome-extensions list | grep -q "dash-to-panel"; then
    echo "Instalando Dash to Panel..."
    # La forma más confiable es usar Extension Manager o instalar manualmente
    echo -e "${YELLOW}Instala Dash to Panel desde: https://extensions.gnome.org/extension/1160/dash-to-panel/${NC}"
    echo -e "${YELLOW}O usa Extension Manager (flatpak run com.mattjakeman.ExtensionManager)${NC}"
else
    echo "Dash to Panel ya está instalado"
fi

# Desktop Icons NG (DING) - ya viene preinstalado en Ubuntu
if gnome-extensions list | grep -q "ding@rastersoft.com"; then
    echo "DING (Desktop Icons) ya está instalado"
fi

# Tiling Assistant - ya viene preinstalado en Ubuntu
if gnome-extensions list | grep -q "tiling-assistant"; then
    echo "Tiling Assistant ya está instalado"
fi

# Restaurar configuración de GNOME desde archivos dconf
echo ""
echo -e "${YELLOW}Restaurando configuración de GNOME...${NC}"

if [ -f "$DOTFILES_DIR/gnome/dash-to-panel.conf" ]; then
    echo "Restaurando configuración de Dash to Panel..."
    dconf load /org/gnome/shell/extensions/dash-to-panel/ < "$DOTFILES_DIR/gnome/dash-to-panel.conf"
fi

if [ -f "$DOTFILES_DIR/gnome/gnome-shell.conf" ]; then
    echo "Restaurando configuración de GNOME Shell..."
    dconf load /org/gnome/shell/ < "$DOTFILES_DIR/gnome/gnome-shell.conf"
fi

if [ -f "$DOTFILES_DIR/gnome/gnome-desktop.conf" ]; then
    echo "Restaurando configuración de GNOME Desktop..."
    dconf load /org/gnome/desktop/ < "$DOTFILES_DIR/gnome/gnome-desktop.conf"
fi

# Habilitar extensiones
echo ""
echo -e "${YELLOW}Habilitando extensiones...${NC}"
if [ -f "$DOTFILES_DIR/gnome/extensions-list.txt" ]; then
    while IFS= read -r extension; do
        if [ ! -z "$extension" ]; then
            gnome-extensions enable "$extension" 2>/dev/null || echo "No se pudo habilitar: $extension"
        fi
    done < "$DOTFILES_DIR/gnome/extensions-list.txt"
fi

echo ""
echo -e "${GREEN}=====================================${NC}"
echo -e "${GREEN}  Configuración completada!${NC}"
echo -e "${GREEN}=====================================${NC}"
echo ""
echo -e "Notas importantes:"
echo -e "  - ${YELLOW}Cierra sesión y vuelve a entrar${NC} para aplicar los cambios"
echo -e "  - Si Dash to Panel no se instaló automáticamente:"
echo -e "    1. Abre Extension Manager: ${YELLOW}flatpak run com.mattjakeman.ExtensionManager${NC}"
echo -e "    2. Busca 'Dash to Panel' e instálalo"
echo -e "    3. La configuración se aplicará automáticamente"
echo ""
echo -e "Para actualizar la configuración de GNOME en el futuro:"
echo -e "  ${YELLOW}cd ~/projects/dotfiles${NC}"
echo -e "  ${YELLOW}./scripts/export-gnome.sh${NC}"
echo ""

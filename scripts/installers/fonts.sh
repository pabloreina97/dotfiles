#!/bin/bash

# Instalador: Fuentes (Fira Code, Fira Code Nerd Font)

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

print_header "Fuentes"

FONT_DIR="$HOME/.local/share/fonts"

# Fira Code (desde repositorios)
print_step "Instalando Fira Code..."
if ! dpkg -s fonts-firacode &> /dev/null; then
    sudo apt install -y fonts-firacode
    print_success "Fira Code instalada"
else
    print_info "Fira Code ya esta instalada"
fi

# Fira Code Nerd Font (con iconos)
print_step "Instalando Fira Code Nerd Font..."
if ! file_exists "$FONT_DIR/FiraCodeNerdFont-Regular.ttf"; then
    mkdir -p "$FONT_DIR"
    cd /tmp
    wget -q https://github.com/ryanoasis/nerd-fonts/releases/latest/download/FiraCode.zip
    unzip -q FiraCode.zip -d FiraCode
    cp FiraCode/*.ttf "$FONT_DIR/"
    rm -rf FiraCode FiraCode.zip
    fc-cache -fv > /dev/null 2>&1
    print_success "Fira Code Nerd Font instalada"
else
    print_info "Fira Code Nerd Font ya esta instalada"
fi

print_success "Fuentes instaladas"

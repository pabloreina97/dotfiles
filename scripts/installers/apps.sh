#!/bin/bash

# Instalador: Aplicaciones (VSCode, Chrome, Flameshot)

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

print_header "Aplicaciones"

# Google Chrome
print_step "Instalando Google Chrome..."
if ! is_installed google-chrome; then
    wget -q -O /tmp/google-chrome.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
    sudo apt install -y /tmp/google-chrome.deb
    rm /tmp/google-chrome.deb
    print_success "Google Chrome instalado"
else
    print_info "Google Chrome ya esta instalado"
fi

# Flameshot
print_step "Instalando Flameshot..."
if ! is_installed flameshot; then
    sudo apt install -y flameshot
    print_success "Flameshot instalado"
    print_info "Atajo recomendado: asignar 'flameshot gui' a Impr Pant"
else
    print_info "Flameshot ya esta instalado"
fi

# VSCode
print_step "Instalando VSCode..."
if ! is_installed code; then
    wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > /tmp/packages.microsoft.gpg
    sudo install -D -o root -g root -m 644 /tmp/packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
    sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
    rm -f /tmp/packages.microsoft.gpg
    sudo apt update
    sudo apt install -y code
    print_success "VSCode instalado"
else
    print_info "VSCode ya esta instalado"
fi

# Instalar extensiones de VSCode
EXTENSIONS_FILE="$DOTFILES_DIR/vscode/extensions.txt"
if file_exists "$EXTENSIONS_FILE"; then
    print_step "Instalando extensiones de VSCode..."
    while IFS= read -r extension; do
        if [ -n "$extension" ] && [[ ! "$extension" =~ ^# ]]; then
            code --install-extension "$extension" --force 2>/dev/null || true
        fi
    done < "$EXTENSIONS_FILE"
    print_success "Extensiones de VSCode instaladas"
else
    print_warning "No se encontro $EXTENSIONS_FILE"
fi

print_success "Aplicaciones instaladas"
print_info "VSCode se sincroniza via Settings Sync (GitHub)"

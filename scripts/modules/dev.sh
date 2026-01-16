#!/bin/bash

# Instalador: Herramientas de desarrollo (NVM, Docker, uv)

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

print_header "Herramientas de Desarrollo"

# NVM (Node Version Manager)
print_step "Instalando NVM..."
if ! dir_exists "$HOME/.nvm"; then
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash

    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

    print_step "Instalando Node.js LTS..."
    nvm install --lts
    nvm use --lts
    print_success "NVM y Node.js LTS instalados"
else
    print_info "NVM ya esta instalado"
fi

# Docker
print_step "Instalando Docker..."
if ! is_installed docker; then
    # Agregar repositorio de Docker
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    sudo apt update
    sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

    # Agregar usuario al grupo docker
    sudo usermod -aG docker "$USER"
    print_success "Docker instalado"
    print_warning "Cierra sesion y vuelve a entrar para usar docker sin sudo"
else
    print_info "Docker ya esta instalado"
fi

# uv (Python version manager)
print_step "Instalando uv..."
if ! is_installed uv; then
    curl -LsSf https://astral.sh/uv/install.sh | sh
    print_success "uv instalado"
    print_warning "Reinicia tu terminal para usar uv"
else
    print_info "uv ya esta instalado"
fi

print_success "Herramientas de desarrollo instaladas"

#!/bin/bash

# Instalador: Sistema base y paquetes esenciales

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

print_header "Sistema y Paquetes Base"

# Actualizar sistema
print_step "Actualizando sistema..."
sudo apt update && sudo apt upgrade -y

# Paquetes esenciales
print_step "Instalando paquetes esenciales..."
sudo apt install -y \
    git \
    curl \
    wget \
    unzip \
    zsh \
    build-essential \
    software-properties-common \
    ca-certificates \
    gnupg \
    lsb-release \
    flatpak

# Agregar repositorio de Flathub
print_step "Configurando Flatpak..."
if ! flatpak remotes | grep -q flathub; then
    sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    print_success "Flathub agregado"
else
    print_info "Flathub ya esta configurado"
fi

print_success "Sistema base instalado correctamente"

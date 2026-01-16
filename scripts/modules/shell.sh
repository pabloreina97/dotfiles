#!/bin/bash

# Instalador: Shell (Zsh, Oh My Zsh, Powerlevel10k, plugins)

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

print_header "Shell (Zsh + Oh My Zsh)"

# Instalar Zsh si no esta
if ! is_installed zsh; then
    print_step "Instalando Zsh..."
    sudo apt install -y zsh
fi

# Oh My Zsh
print_step "Instalando Oh My Zsh..."
if ! dir_exists "$HOME/.oh-my-zsh"; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    print_success "Oh My Zsh instalado"
else
    print_info "Oh My Zsh ya esta instalado"
fi

# Powerlevel10k
print_step "Instalando Powerlevel10k..."
P10K_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
if ! dir_exists "$P10K_DIR"; then
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$P10K_DIR"
    print_success "Powerlevel10k instalado"
else
    print_info "Powerlevel10k ya esta instalado"
fi

# zsh-autosuggestions
print_step "Instalando zsh-autosuggestions..."
AUTOSUGGESTIONS_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions"
if ! dir_exists "$AUTOSUGGESTIONS_DIR"; then
    git clone https://github.com/zsh-users/zsh-autosuggestions "$AUTOSUGGESTIONS_DIR"
    print_success "zsh-autosuggestions instalado"
else
    print_info "zsh-autosuggestions ya esta instalado"
fi

# zsh-syntax-highlighting
print_step "Instalando zsh-syntax-highlighting..."
SYNTAX_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting"
if ! dir_exists "$SYNTAX_DIR"; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$SYNTAX_DIR"
    print_success "zsh-syntax-highlighting instalado"
else
    print_info "zsh-syntax-highlighting ya esta instalado"
fi

# Cambiar shell a zsh
if [ "$SHELL" != "$(which zsh)" ]; then
    print_step "Cambiando shell a zsh..."
    chsh -s "$(which zsh)"
    print_success "Shell cambiado a zsh (requiere reinicio de sesion)"
fi

# Aplicar tema One Dark al terminal
print_step "Aplicando tema One Dark..."
if is_installed dconf; then
    # Instalar dependencias de Gogh
    if ! is_installed uuid-runtime; then
        sudo apt install -y dconf-cli uuid-runtime
    fi
    # Descargar y aplicar tema One Dark (247) con Gogh
    export TERMINAL=gnome-terminal
    bash -c "$(wget -qO- https://git.io/vQgMr)" <<< "247
"
    print_success "Tema One Dark aplicado"
    print_info "Selecciona el perfil 'One Dark' en preferencias del terminal"
else
    print_warning "dconf no instalado, saltando tema"
fi

print_success "Shell configurado correctamente"
print_info "Ejecuta el modulo 'config' para personalizar tu .zshrc"

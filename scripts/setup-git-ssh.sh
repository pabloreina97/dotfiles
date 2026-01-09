#!/bin/bash

# Configurador: Git y SSH para GitHub
# Este script es interactivo y se puede ejecutar independientemente

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/common.sh"

print_header "Configuracion Git y SSH"

# Configuracion de Git
print_step "Configurando Git..."
if ! file_exists "$HOME/.gitconfig" || [ ! -s "$HOME/.gitconfig" ]; then
    read -p "Nombre para Git: " git_name
    read -p "Email para Git: " git_email
    git config --global user.name "$git_name"
    git config --global user.email "$git_email"
    print_success "Git configurado"
else
    print_info "Git ya esta configurado"
    print_info "Usuario: $(git config --global user.name)"
    print_info "Email: $(git config --global user.email)"
fi

# SSH Key para GitHub
print_step "Configurando SSH key para GitHub..."
if ! file_exists "$HOME/.ssh/id_ed25519"; then
    read -p "Email para SSH key (usar el mismo de GitHub): " ssh_email
    ssh-keygen -t ed25519 -C "$ssh_email" -f "$HOME/.ssh/id_ed25519" -N ""

    # Iniciar ssh-agent y agregar la key
    eval "$(ssh-agent -s)"
    ssh-add "$HOME/.ssh/id_ed25519"

    echo ""
    print_success "SSH key generada!"
    print_warning "Copia esta clave publica y agregala a GitHub:"
    print_info "https://github.com/settings/keys"
    echo ""
    echo -e "${YELLOW}$(cat "$HOME/.ssh/id_ed25519.pub")${NC}"
    echo ""
    read -p "Presiona Enter cuando hayas agregado la clave a GitHub..."
else
    print_info "SSH key ya existe en ~/.ssh/id_ed25519"
    print_info "Clave publica:"
    echo ""
    cat "$HOME/.ssh/id_ed25519.pub"
    echo ""
fi

print_success "Git y SSH configurados"

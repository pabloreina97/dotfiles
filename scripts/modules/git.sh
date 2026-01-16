#!/bin/bash

# Modulo: Git, SSH y GitHub CLI
# Configura git, genera SSH key y autentica con GitHub

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

print_header "Git, SSH y GitHub"

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
print_step "Configurando SSH key..."
SSH_KEY_CREATED=false
if ! file_exists "$HOME/.ssh/id_ed25519"; then
    # Usar el email de git si existe, sino preguntar
    ssh_email=$(git config --global user.email 2>/dev/null || echo "")
    if [[ -z "$ssh_email" ]]; then
        read -p "Email para SSH key: " ssh_email
    else
        print_info "Usando email: $ssh_email"
    fi

    ssh-keygen -t ed25519 -C "$ssh_email" -f "$HOME/.ssh/id_ed25519" -N ""

    # Iniciar ssh-agent y agregar la key
    eval "$(ssh-agent -s)" > /dev/null
    ssh-add "$HOME/.ssh/id_ed25519" 2>/dev/null

    print_success "SSH key generada"
    SSH_KEY_CREATED=true
else
    print_info "SSH key ya existe en ~/.ssh/id_ed25519"
fi

# GitHub CLI auth
print_step "Autenticando con GitHub..."
if is_installed gh; then
    if ! gh auth status &>/dev/null; then
        print_info "Se abrira el navegador para autenticarte con GitHub"
        print_info "gh auth login tambien subira tu SSH key a GitHub"
        echo ""
        read -p "Presiona Enter para continuar..."

        # Auth con GitHub, protocolo SSH, sube la key
        gh auth login --git-protocol ssh --web

        # Subir SSH key si se acaba de crear
        if [[ "$SSH_KEY_CREATED" == true ]]; then
            print_step "Subiendo SSH key a GitHub..."
            gh ssh-key add "$HOME/.ssh/id_ed25519.pub" --title "$(hostname)" 2>/dev/null || print_info "SSH key ya existe en GitHub"
        fi

        print_success "Autenticado con GitHub"
    else
        print_info "Ya estas autenticado con GitHub"
        gh auth status
    fi
else
    print_warning "GitHub CLI (gh) no esta instalado"
    print_info "Instala el modulo 'cli' primero, o sube la SSH key manualmente:"
    echo ""
    cat "$HOME/.ssh/id_ed25519.pub"
    echo ""
fi

print_success "Git, SSH y GitHub configurados"

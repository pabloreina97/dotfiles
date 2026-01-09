#!/bin/bash

# Instalador: Herramientas CLI modernas

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

print_header "Herramientas CLI"

# GitHub CLI
print_step "Instalando GitHub CLI..."
if ! is_installed gh; then
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
    sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
    sudo apt update
    sudo apt install -y gh
    print_success "GitHub CLI instalado"
    print_info "Ejecuta 'gh auth login' para autenticarte"
else
    print_info "GitHub CLI ya esta instalado"
fi

# Claude Code
print_step "Instalando Claude Code..."
if ! is_installed claude; then
    curl -fsSL https://claude.ai/install.sh | bash

    # Recargar PATH para verificar instalacion
    export PATH="$HOME/.local/bin:$PATH"

    if is_installed claude; then
        print_success "Claude Code instalado en ~/.local/bin"
        print_info "Ejecuta 'claude' para iniciar"
    else
        print_warning "Claude Code instalado, reinicia la terminal para usarlo"
    fi
else
    print_info "Claude Code ya esta instalado ($(which claude))"
fi

# bat (cat con syntax highlighting)
print_step "Instalando bat..."
if ! is_installed batcat; then
    sudo apt install -y bat
    mkdir -p ~/.local/bin
    ln -sf /usr/bin/batcat ~/.local/bin/bat 2>/dev/null || true
    print_success "bat instalado"
else
    print_info "bat ya esta instalado"
fi

# eza (ls moderno)
print_step "Instalando eza..."
if ! is_installed eza; then
    sudo mkdir -p /etc/apt/keyrings
    wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
    echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list
    sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
    sudo apt update
    sudo apt install -y eza
    print_success "eza instalado"
else
    print_info "eza ya esta instalado"
fi

# tldr (ayuda simplificada)
print_step "Instalando tldr..."
if ! is_installed tldr; then
    sudo apt install -y tldr
    print_success "tldr instalado"
else
    print_info "tldr ya esta instalado"
fi

# micro (editor moderno)
print_step "Instalando micro..."
if ! is_installed micro; then
    cd /tmp
    curl https://getmic.ro | bash
    sudo mv micro /usr/local/bin/
    print_success "micro instalado"
else
    print_info "micro ya esta instalado"
fi

# htop (monitor de sistema)
print_step "Instalando htop..."
if ! is_installed htop; then
    sudo apt install -y htop
    print_success "htop instalado"
else
    print_info "htop ya esta instalado"
fi

# jq (procesar JSON)
print_step "Instalando jq..."
if ! is_installed jq; then
    sudo apt install -y jq
    print_success "jq instalado"
else
    print_info "jq ya esta instalado"
fi

# ripgrep (busqueda rapida)
print_step "Instalando ripgrep..."
if ! is_installed rg; then
    sudo apt install -y ripgrep
    print_success "ripgrep instalado"
else
    print_info "ripgrep ya esta instalado"
fi

# fd-find (find moderno)
print_step "Instalando fd-find..."
if ! is_installed fdfind; then
    sudo apt install -y fd-find
    mkdir -p ~/.local/bin
    ln -sf /usr/bin/fdfind ~/.local/bin/fd 2>/dev/null || true
    print_success "fd-find instalado"
else
    print_info "fd-find ya esta instalado"
fi

# tree (visualizar directorios)
print_step "Instalando tree..."
if ! is_installed tree; then
    sudo apt install -y tree
    print_success "tree instalado"
else
    print_info "tree ya esta instalado"
fi

print_success "Herramientas CLI instaladas"

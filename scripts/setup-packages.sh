#!/bin/bash

# Script para instalar paquetes esenciales en Ubuntu
# Ejecutar después de install.sh en una instalación nueva

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}=====================================${NC}"
echo -e "${GREEN}  Instalación de Paquetes Ubuntu${NC}"
echo -e "${GREEN}=====================================${NC}"
echo ""

# Actualizar sistema
echo -e "${YELLOW}Actualizando sistema...${NC}"
sudo apt update && sudo apt upgrade -y

# Paquetes esenciales
echo ""
echo -e "${YELLOW}Instalando paquetes esenciales...${NC}"
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
    flatpak \
    gnome-software-plugin-flatpak

# Agregar repositorio de Flathub
if ! flatpak remotes | grep -q flathub; then
    echo "Agregando repositorio Flathub..."
    sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
fi

# Git
echo ""
echo -e "${YELLOW}Configurando Git...${NC}"
if [ ! -f ~/.gitconfig ]; then
    read -p "Nombre para Git: " git_name
    read -p "Email para Git: " git_email
    git config --global user.name "$git_name"
    git config --global user.email "$git_email"
fi

# SSH Key para GitHub
echo ""
echo -e "${YELLOW}Configurando SSH key para GitHub...${NC}"
if [ ! -f ~/.ssh/id_ed25519 ]; then
    read -p "Email para SSH key (usar el mismo de GitHub): " ssh_email
    ssh-keygen -t ed25519 -C "$ssh_email" -f ~/.ssh/id_ed25519 -N ""

    # Iniciar ssh-agent y agregar la key
    eval "$(ssh-agent -s)"
    ssh-add ~/.ssh/id_ed25519

    echo ""
    echo -e "${GREEN}SSH key generada!${NC}"
    echo -e "${YELLOW}Copia esta clave pública y agrégala a GitHub:${NC}"
    echo -e "${YELLOW}https://github.com/settings/keys${NC}"
    echo ""
    cat ~/.ssh/id_ed25519.pub
    echo ""
    read -p "Presiona Enter cuando hayas agregado la clave a GitHub..."
else
    echo "SSH key ya existe en ~/.ssh/id_ed25519"
fi

# Oh My Zsh
echo ""
echo -e "${YELLOW}Instalando Oh My Zsh...${NC}"
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

    # Instalar Powerlevel10k
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k

    # Plugins útiles
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
else
    echo "Oh My Zsh ya está instalado"
fi

# Cambiar shell a zsh
if [ "$SHELL" != "$(which zsh)" ]; then
    echo ""
    echo -e "${YELLOW}Cambiando shell a zsh...${NC}"
    chsh -s $(which zsh)
fi

# NVM (Node Version Manager)
echo ""
echo -e "${YELLOW}Instalando NVM...${NC}"
if [ ! -d "$HOME/.nvm" ]; then
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash

    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

    nvm install --lts
    nvm use --lts
else
    echo "NVM ya está instalado"
fi

# Docker
echo ""
echo -e "${YELLOW}Instalando Docker...${NC}"
if ! command -v docker &> /dev/null; then
    # Agregar repositorio de Docker
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    sudo apt update
    sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

    # Agregar usuario al grupo docker
    sudo usermod -aG docker $USER
    echo -e "${GREEN}Docker instalado. Necesitas cerrar sesión y volver a entrar para usar docker sin sudo${NC}"
else
    echo "Docker ya está instalado"
fi

# GitHub CLI
echo ""
echo -e "${YELLOW}Instalando GitHub CLI...${NC}"
if ! command -v gh &> /dev/null; then
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
    sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null

    sudo apt update
    sudo apt install -y gh
else
    echo "GitHub CLI ya está instalado"
fi

# Google Cloud SDK (opcional - comentado por defecto)
# echo ""
# echo -e "${YELLOW}Instalando Google Cloud SDK...${NC}"
# if ! command -v gcloud &> /dev/null; then
#     echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
#     curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -
#     sudo apt update && sudo apt install -y google-cloud-sdk
# fi

# Claude CLI
echo ""
echo -e "${YELLOW}Instalando Claude CLI...${NC}"
if ! command -v claude &> /dev/null; then
    curl -fsSL https://releases.anthropic.com/claude/install.sh | sh
    echo -e "${GREEN}Claude CLI instalado${NC}"
    echo -e "${YELLOW}Ejecuta 'claude auth login' para autenticarte${NC}"
else
    echo "Claude CLI ya está instalado"
fi

# Google Chrome
echo ""
echo -e "${YELLOW}Instalando Google Chrome...${NC}"
if ! command -v google-chrome &> /dev/null; then
    wget -q -O /tmp/google-chrome.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
    sudo apt install -y /tmp/google-chrome.deb
    rm /tmp/google-chrome.deb
    echo -e "${GREEN}Google Chrome instalado${NC}"
else
    echo "Google Chrome ya está instalado"
fi

# Herramientas CLI modernas
echo ""
echo -e "${YELLOW}Instalando herramientas CLI modernas...${NC}"

# bat (cat con syntax highlighting)
if ! command -v batcat &> /dev/null; then
    sudo apt install -y bat
    # Crear alias bat -> batcat si no existe
    mkdir -p ~/.local/bin
    ln -sf /usr/bin/batcat ~/.local/bin/bat 2>/dev/null || true
    echo -e "${GREEN}bat instalado${NC}"
else
    echo "bat ya está instalado"
fi

# eza (ls moderno)
if ! command -v eza &> /dev/null; then
    sudo mkdir -p /etc/apt/keyrings
    wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
    echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list
    sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
    sudo apt update
    sudo apt install -y eza
    echo -e "${GREEN}eza instalado${NC}"
else
    echo "eza ya está instalado"
fi

# tldr (ayuda simplificada de comandos)
if ! command -v tldr &> /dev/null; then
    sudo apt install -y tldr
    echo -e "${GREEN}tldr instalado${NC}"
else
    echo "tldr ya está instalado"
fi

# micro (editor de texto moderno)
if ! command -v micro &> /dev/null; then
    cd /tmp
    curl https://getmic.ro | bash
    sudo mv micro /usr/local/bin/
    echo -e "${GREEN}micro instalado${NC}"
else
    echo "micro ya está instalado"
fi

# Fira Code Nerd Font
echo ""
echo -e "${YELLOW}Instalando Fira Code Nerd Font...${NC}"
FONT_DIR="$HOME/.local/share/fonts"
if [ ! -f "$FONT_DIR/FiraCodeNerdFont-Regular.ttf" ]; then
    mkdir -p "$FONT_DIR"
    cd /tmp
    wget -q https://github.com/ryanoasis/nerd-fonts/releases/latest/download/FiraCode.zip
    unzip -q FiraCode.zip -d FiraCode
    cp FiraCode/*.ttf "$FONT_DIR/"
    rm -rf FiraCode FiraCode.zip
    fc-cache -fv
    echo -e "${GREEN}Fira Code Nerd Font instalada${NC}"
else
    echo "Fira Code Nerd Font ya está instalada"
fi

# uv (gestor de versiones de Python)
echo ""
echo -e "${YELLOW}Instalando uv (Python version manager)...${NC}"
if ! command -v uv &> /dev/null; then
    curl -LsSf https://astral.sh/uv/install.sh | sh
    echo -e "${GREEN}uv instalado${NC}"
    echo -e "${YELLOW}Reinicia tu terminal para usar uv${NC}"
else
    echo "uv ya está instalado"
fi

# VSCode
echo ""
echo -e "${YELLOW}Instalando VSCode...${NC}"
if ! command -v code &> /dev/null; then
    wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
    sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
    sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
    rm -f packages.microsoft.gpg

    sudo apt update
    sudo apt install -y code
else
    echo "VSCode ya está instalado"
fi

# Instalar extensiones de VSCode
if [ -f "$HOME/projects/dotfiles/vscode/extensions.txt" ]; then
    echo ""
    echo -e "${YELLOW}Instalando extensiones de VSCode...${NC}"
    while IFS= read -r extension; do
        if [ ! -z "$extension" ] && [[ ! "$extension" =~ ^# ]]; then
            code --install-extension "$extension" || true
        fi
    done < "$HOME/projects/dotfiles/vscode/extensions.txt"
fi

echo ""
echo -e "${GREEN}=====================================${NC}"
echo -e "${GREEN}  Instalación completada!${NC}"
echo -e "${GREEN}=====================================${NC}"
echo ""
echo -e "Notas importantes:"
echo -e "  - Reinicia tu terminal para aplicar los cambios de zsh"
echo -e "  - Si instalaste Docker, cierra sesión y vuelve a entrar"
echo ""
echo -e "Autenticación de servicios:"
echo -e "  - GitHub CLI:      ${YELLOW}gh auth login${NC}"
echo -e "  - Claude CLI:      ${YELLOW}claude auth login${NC}"
echo -e "  - Google Cloud:    ${YELLOW}gcloud auth login${NC} (si instalaste gcloud)"
echo -e "  - Docker Hub:      ${YELLOW}docker login${NC} (si necesitas push a Docker Hub)"
echo ""
echo -e "Tu SSH key está en: ${YELLOW}~/.ssh/id_ed25519.pub${NC}"
echo ""

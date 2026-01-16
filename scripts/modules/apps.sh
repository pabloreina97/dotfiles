#!/bin/bash

# Modulo: Aplicaciones con selector individual

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

print_header "Aplicaciones"

# Definir apps disponibles
declare -A APPS=(
    ["chrome"]="Google Chrome"
    ["vscode"]="Visual Studio Code"
    ["slack"]="Slack"
    ["flameshot"]="Flameshot (capturas)"
    ["rustdesk"]="RustDesk (escritorio remoto)"
    ["claude"]="Claude Code CLI"
    ["gcloud"]="Google Cloud CLI"
    ["terraform"]="Terraform (HashiCorp)"
    ["rm-firefox"]="[Desinstalar] Firefox"
)

# Orden de apps en el menu
APP_ORDER=("chrome" "vscode" "slack" "flameshot" "rustdesk" "claude" "gcloud" "terraform" "rm-firefox")

# Funciones de instalacion para cada app
install_chrome() {
    if ! is_installed google-chrome; then
        print_step "Instalando Google Chrome..."
        wget -q -O /tmp/google-chrome.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
        sudo apt install -y /tmp/google-chrome.deb
        rm /tmp/google-chrome.deb
        print_success "Google Chrome instalado"
    else
        print_info "Google Chrome ya esta instalado"
    fi
}

install_vscode() {
    if ! is_installed code; then
        print_step "Instalando VSCode..."
        wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > /tmp/packages.microsoft.gpg
        sudo install -D -o root -g root -m 644 /tmp/packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
        echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | sudo tee /etc/apt/sources.list.d/vscode.list > /dev/null
        rm -f /tmp/packages.microsoft.gpg
        sudo apt update
        sudo apt install -y code
        print_success "VSCode instalado"
    else
        print_info "VSCode ya esta instalado"
    fi
}

install_slack() {
    if ! snap list slack &>/dev/null; then
        print_step "Instalando Slack..."
        sudo snap install slack
        print_success "Slack instalado"
    else
        print_info "Slack ya esta instalado"
    fi
}

install_flameshot() {
    if ! is_installed flameshot; then
        print_step "Instalando Flameshot..."
        sudo apt install -y flameshot
        print_success "Flameshot instalado"
        print_info "Atajo recomendado: asignar 'flameshot gui' a Impr Pant"
    else
        print_info "Flameshot ya esta instalado"
    fi
}

install_rustdesk() {
    if ! is_installed rustdesk; then
        print_step "Instalando RustDesk..."
        local version
        version=$(curl -s https://api.github.com/repos/rustdesk/rustdesk/releases/latest | grep -Po '"tag_name": "\K[^"]*')
        wget -q -O /tmp/rustdesk.deb "https://github.com/rustdesk/rustdesk/releases/download/${version}/rustdesk-${version}-x86_64.deb"
        sudo apt install -y /tmp/rustdesk.deb
        rm /tmp/rustdesk.deb
        print_success "RustDesk instalado"
    else
        print_info "RustDesk ya esta instalado"
    fi
}

install_claude() {
    if ! is_installed claude; then
        print_step "Instalando Claude Code..."
        curl -fsSL https://claude.ai/install.sh | bash
        export PATH="$HOME/.local/bin:$PATH"
        if is_installed claude; then
            print_success "Claude Code instalado"
            print_info "Ejecuta 'claude' para iniciar"
        else
            print_warning "Claude Code instalado, reinicia la terminal para usarlo"
        fi
    else
        print_info "Claude Code ya esta instalado"
    fi
}

install_gcloud() {
    if ! is_installed gcloud; then
        print_step "Instalando Google Cloud CLI..."

        # Instalar dependencias
        sudo apt install -y apt-transport-https ca-certificates gnupg curl

        # Añadir repo de Google Cloud
        curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg
        echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee /etc/apt/sources.list.d/google-cloud-sdk.list > /dev/null

        sudo apt update
        sudo apt install -y google-cloud-cli

        print_success "Google Cloud CLI instalado"
    else
        print_info "Google Cloud CLI ya esta instalado"
    fi

    # Autenticacion con Google Cloud
    print_step "Configurando autenticacion de Google Cloud..."

    # gcloud auth login
    if ! gcloud auth list --filter=status:ACTIVE --format="value(account)" 2>/dev/null | grep -q .; then
        print_info "Se abrira el navegador para autenticarte con Google Cloud"
        read -p "Presiona Enter para continuar..."
        gcloud auth login
        print_success "Autenticado con gcloud"
    else
        print_info "Ya hay una cuenta activa: $(gcloud auth list --filter=status:ACTIVE --format='value(account)')"
    fi

    # Application Default Credentials
    if ! file_exists "$HOME/.config/gcloud/application_default_credentials.json"; then
        print_step "Configurando Application Default Credentials..."
        print_info "Se abrira el navegador para configurar ADC"
        read -p "Presiona Enter para continuar..."
        gcloud auth application-default login
        print_success "Application Default Credentials configuradas"
    else
        print_info "Application Default Credentials ya existen"
    fi
}

install_terraform() {
    if ! is_installed terraform; then
        print_step "Instalando Terraform..."

        # Instalar dependencias
        sudo apt install -y gnupg software-properties-common

        # Añadir repo de HashiCorp
        wget -qO- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
        echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list > /dev/null

        sudo apt update
        sudo apt install -y terraform

        print_success "Terraform instalado"
    else
        print_info "Terraform ya esta instalado ($(terraform version -json | jq -r '.terraform_version'))"
    fi
}

remove_firefox() {
    # Firefox puede estar instalado como snap o apt
    if snap list firefox &>/dev/null; then
        print_step "Desinstalando Firefox (snap)..."
        sudo snap remove firefox
        print_success "Firefox desinstalado"
    elif dpkg -s firefox &>/dev/null; then
        print_step "Desinstalando Firefox (apt)..."
        sudo apt remove -y firefox
        sudo apt autoremove -y
        print_success "Firefox desinstalado"
    else
        print_info "Firefox no esta instalado"
    fi
}

# Mostrar selector de apps
select_apps() {
    # Verificar que whiptail este instalado
    if ! is_installed whiptail; then
        sudo apt install -y whiptail
    fi

    local options=()
    for app in "${APP_ORDER[@]}"; do
        # Algunas apps OFF por defecto
        if [[ "$app" == "rm-firefox" || "$app" == "gcloud" || "$app" == "terraform" ]]; then
            options+=("$app" "${APPS[$app]}" "OFF")
        else
            options+=("$app" "${APPS[$app]}" "ON")
        fi
    done

    local selected
    selected=$(whiptail --title "Aplicaciones" \
        --checklist "Selecciona las aplicaciones a instalar/desinstalar:" 22 60 8 \
        "${options[@]}" \
        3>&1 1>&2 2>&3) || return 0

    echo "$selected" | tr -d '"'
}

# Main
main() {
    local selected_apps
    selected_apps=$(select_apps)

    if [[ -z "$selected_apps" ]]; then
        print_info "No se selecciono ninguna aplicacion"
        return 0
    fi

    for app in $selected_apps; do
        case "$app" in
            chrome)     install_chrome ;;
            vscode)     install_vscode ;;
            slack)      install_slack ;;
            flameshot)  install_flameshot ;;
            rustdesk)   install_rustdesk ;;
            claude)     install_claude ;;
            gcloud)     install_gcloud ;;
            terraform)  install_terraform ;;
            rm-firefox) remove_firefox ;;
        esac
    done

    print_success "Aplicaciones instaladas"
}

main

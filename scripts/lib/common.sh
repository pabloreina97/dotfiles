#!/bin/bash

# Funciones compartidas para scripts de instalacion
# Uso: source "$(dirname "$0")/lib/common.sh"

# Colores para terminal
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Tema sobrio para whiptail (grises)
export NEWT_COLORS='
root=white,black
border=white,black
window=white,black
shadow=black,black
title=white,black
button=black,white
actbutton=black,cyan
checkbox=white,black
actcheckbox=black,cyan
compactbutton=white,black
entry=white,black
label=white,black
listbox=white,black
actlistbox=black,white
textbox=white,black
acttextbox=black,white
helpline=black,white
roottext=white,black
sellistbox=black,cyan
actsellistbox=black,cyan
'

# Directorio base del repositorio
DOTFILES_DIR="$HOME/projects/dotfiles"

# Imprimir banner/header
print_header() {
    echo ""
    echo -e "${GREEN}=====================================${NC}"
    echo -e "${GREEN}  $1${NC}"
    echo -e "${GREEN}=====================================${NC}"
    echo ""
}

# Imprimir paso de instalacion
print_step() {
    echo -e "${YELLOW}>> $1${NC}"
}

# Imprimir mensaje de exito
print_success() {
    echo -e "${GREEN}[OK]${NC} $1"
}

# Imprimir advertencia
print_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

# Imprimir error
print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Imprimir info
print_info() {
    echo -e "${BLUE}[i]${NC} $1"
}

# Verificar si un comando existe
is_installed() {
    command -v "$1" &> /dev/null
}

# Verificar si un directorio existe
dir_exists() {
    [ -d "$1" ]
}

# Verificar si un archivo existe
file_exists() {
    [ -f "$1" ]
}

# Instalar paquete apt si no esta instalado
apt_install() {
    local package="$1"
    if ! dpkg -s "$package" &> /dev/null; then
        sudo apt install -y "$package"
        return 0
    fi
    return 1
}

# Obtener el directorio del script que llama
get_script_dir() {
    cd "$(dirname "${BASH_SOURCE[1]}")" && pwd
}

# Obtener directorio raiz de scripts
get_scripts_dir() {
    echo "$DOTFILES_DIR/scripts"
}

# Detectar display server (X11 o Wayland)
detect_display_server() {
    if [[ "$XDG_SESSION_TYPE" == "wayland" ]]; then
        echo "wayland"
    else
        echo "x11"
    fi
}

# Instalar clipboard segun display server
install_clipboard() {
    local display=$(detect_display_server)
    print_step "Detectado: $display"
    if [[ "$display" == "wayland" ]]; then
        if ! is_installed wl-copy; then
            sudo apt install -y wl-clipboard
            print_success "wl-clipboard instalado (Wayland)"
        else
            print_info "wl-clipboard ya esta instalado"
        fi
    else
        if ! is_installed xclip; then
            sudo apt install -y xclip
            print_success "xclip instalado (X11)"
        else
            print_info "xclip ya esta instalado"
        fi
    fi
}

# Mostrar checklist con whiptail
show_checklist() {
    local title="$1"
    local prompt="$2"
    shift 2
    local options=("$@")

    whiptail --title "$title" \
        --checklist "$prompt" 20 70 10 \
        "${options[@]}" \
        3>&1 1>&2 2>&3
}

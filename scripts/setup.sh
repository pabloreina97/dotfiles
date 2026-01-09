#!/bin/bash

# Script principal de instalacion con menu interactivo
# Uso:
#   ./setup.sh              Muestra menu interactivo
#   ./setup.sh --all        Instala todo sin preguntar
#   ./setup.sh --only X,Y   Instala solo componentes especificados

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/common.sh"

# Componentes disponibles
declare -A COMPONENTS=(
    ["system"]="Sistema (actualizacion + paquetes base)"
    ["shell"]="Shell (Zsh + Oh My Zsh + tema)"
    ["git-ssh"]="Git y SSH"
    ["dev-tools"]="Herramientas Dev (Node, Docker, uv)"
    ["cli-tools"]="CLI Tools (gh, claude, bat, eza...)"
    ["apps"]="Aplicaciones (VSCode, Chrome, Flameshot)"
    ["fonts"]="Fuentes (Fira Code, Nerd Font)"
)

# Orden de instalacion
INSTALL_ORDER=("system" "shell" "git-ssh" "dev-tools" "cli-tools" "apps" "fonts")

# Ejecutar instalador
run_installer() {
    local component="$1"
    case "$component" in
        system)    bash "$SCRIPT_DIR/installers/system.sh" ;;
        shell)     bash "$SCRIPT_DIR/installers/shell.sh" ;;
        git-ssh)   bash "$SCRIPT_DIR/setup-git-ssh.sh" ;;
        dev-tools) bash "$SCRIPT_DIR/installers/dev-tools.sh" ;;
        cli-tools) bash "$SCRIPT_DIR/installers/cli-tools.sh" ;;
        apps)      bash "$SCRIPT_DIR/installers/apps.sh" ;;
        fonts)     bash "$SCRIPT_DIR/installers/fonts.sh" ;;
        *)         print_error "Componente desconocido: $component" ;;
    esac
}

# Instalar componentes seleccionados
install_components() {
    local components=("$@")

    for comp in "${INSTALL_ORDER[@]}"; do
        for selected in "${components[@]}"; do
            if [ "$comp" = "$selected" ]; then
                run_installer "$comp"
                break
            fi
        done
    done
}

# Menu interactivo con whiptail
show_menu() {
    # Verificar que whiptail este instalado
    if ! is_installed whiptail; then
        sudo apt install -y whiptail
    fi

    local options=()
    for comp in "${INSTALL_ORDER[@]}"; do
        options+=("$comp" "${COMPONENTS[$comp]}" "ON")
    done

    local selected
    selected=$(whiptail --title "Instalacion de Dotfiles Ubuntu" \
        --checklist "Selecciona los componentes a instalar:" 20 70 7 \
        "${options[@]}" \
        3>&1 1>&2 2>&3) || exit 0

    # Convertir seleccion a array
    selected=$(echo "$selected" | tr -d '"')
    read -ra SELECTED_COMPONENTS <<< "$selected"

    if [ ${#SELECTED_COMPONENTS[@]} -eq 0 ]; then
        print_warning "No se selecciono ningun componente"
        exit 0
    fi

    echo ""
    print_header "Instalando componentes seleccionados"
    install_components "${SELECTED_COMPONENTS[@]}"
}

# Mostrar ayuda
show_help() {
    echo "Uso: $0 [OPCION]"
    echo ""
    echo "Opciones:"
    echo "  (sin argumentos)    Muestra menu interactivo"
    echo "  --all               Instala todos los componentes"
    echo "  --only X,Y,Z        Instala solo los componentes especificados"
    echo "  --list              Lista los componentes disponibles"
    echo "  --help              Muestra esta ayuda"
    echo ""
    echo "Componentes disponibles:"
    for comp in "${INSTALL_ORDER[@]}"; do
        echo "  $comp - ${COMPONENTS[$comp]}"
    done
}

# Listar componentes
list_components() {
    echo "Componentes disponibles:"
    echo ""
    for comp in "${INSTALL_ORDER[@]}"; do
        echo "  $comp"
        echo "    ${COMPONENTS[$comp]}"
        echo ""
    done
}

# Main
main() {
    print_header "Instalacion de Dotfiles Ubuntu"

    case "${1:-}" in
        --all)
            print_step "Instalando todos los componentes..."
            install_components "${INSTALL_ORDER[@]}"
            ;;
        --only)
            if [ -z "${2:-}" ]; then
                print_error "Especifica los componentes: --only system,shell,dev-tools"
                exit 1
            fi
            IFS=',' read -ra SELECTED <<< "$2"
            print_step "Instalando: ${SELECTED[*]}"
            install_components "${SELECTED[@]}"
            ;;
        --list)
            list_components
            exit 0
            ;;
        --help|-h)
            show_help
            exit 0
            ;;
        "")
            show_menu
            ;;
        *)
            print_error "Opcion desconocida: $1"
            show_help
            exit 1
            ;;
    esac

    # Mensaje final
    echo ""
    print_header "Instalacion completada!"
    echo ""
    print_warning "IMPORTANTE: Ahora ejecuta el script de symlinks:"
    echo "  cd ~/projects/dotfiles && ./install.sh"
    echo ""
    print_info "Esto sobrescribira el .zshrc de Oh My Zsh con tu configuracion personalizada."
    echo ""
    print_info "Notas importantes:"
    echo "  - Reinicia tu terminal para aplicar los cambios de zsh"
    echo "  - Si instalaste Docker, cierra sesion y vuelve a entrar"
    echo ""
    print_info "Autenticacion de servicios:"
    echo "  - GitHub CLI:  gh auth login"
    echo "  - Claude CLI:  claude auth login"
    echo "  - Docker Hub:  docker login"
    echo ""
}

main "$@"

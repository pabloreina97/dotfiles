#!/bin/bash

# Modulo: Personalizar configuraciones (zshrc, bashrc)
# Abre los templates con micro para editar y guarda en ~/

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

# Directorios de configuracion
TEMPLATES_DIR="$(cd "$SCRIPT_DIR/../../shell" && pwd)"
CLAUDE_DIR="$(cd "$SCRIPT_DIR/../../claude" && pwd)"

print_header "Personalizar Configuraciones"

# Funcion para editar y guardar config
edit_config() {
    local template="$1"
    local dest="$2"
    local name="$3"

    if ! file_exists "$template"; then
        print_error "Template no encontrado: $template"
        return 1
    fi

    # Verificar que micro este instalado
    if ! is_installed micro; then
        print_warning "micro no esta instalado, instalando..."
        cd /tmp
        curl -fsSL https://getmic.ro | bash
        sudo mv micro /usr/local/bin/
    fi

    print_step "Editando $name..."
    print_info "Se abrira micro con el template. Edita y guarda con Ctrl+S, sal con Ctrl+Q"
    echo ""
    read -p "Presiona Enter para abrir el editor..."

    # Copiar template a temporal
    local temp_file="/tmp/${name}.tmp.$$"
    cp "$template" "$temp_file"

    # Abrir con micro
    micro "$temp_file"

    # Preguntar si guardar
    echo ""
    read -p "¿Guardar en $dest? [S/n]: " confirm
    confirm=${confirm:-S}

    if [[ "$confirm" =~ ^[Ss]$ ]]; then
        # Hacer backup si existe
        if file_exists "$dest"; then
            local backup="$dest.backup.$(date +%Y%m%d_%H%M%S)"
            mv "$dest" "$backup"
            print_info "Backup creado: $backup"
        fi
        mv "$temp_file" "$dest"
        print_success "$name guardado en $dest"
    else
        rm -f "$temp_file"
        print_warning "$name no guardado"
    fi
}

# Funcion para copiar config de Claude
copy_claude_config() {
    local source="$CLAUDE_DIR/settings.json"
    local dest="$HOME/.claude/settings.json"

    if ! file_exists "$source"; then
        print_error "Config de Claude no encontrada: $source"
        return 1
    fi

    print_step "Configurando Claude Code..."

    # Crear directorio si no existe
    mkdir -p "$HOME/.claude"

    # Hacer backup si existe
    if file_exists "$dest"; then
        local backup="$dest.backup.$(date +%Y%m%d_%H%M%S)"
        cp "$dest" "$backup"
        print_info "Backup creado: $backup"
    fi

    # Copiar config
    cp "$source" "$dest"
    print_success "Claude configurado en $dest"
    print_info "Permissions seguras aplicadas (git, npm, python, docker...)"
}

# Selector de configs a editar
select_configs() {
    if ! is_installed whiptail; then
        sudo apt install -y whiptail
    fi

    local options=(
        "zshrc" "Configuracion de Zsh (editable)" "ON"
        "bashrc" "Configuracion de Bash (editable)" "OFF"
        "claude" "Claude Code settings + permissions" "ON"
    )

    local selected
    selected=$(whiptail --title "Configuraciones" \
        --checklist "Selecciona las configuraciones a personalizar:" 14 60 3 \
        "${options[@]}" \
        3>&1 1>&2 2>&3) || return 0

    echo "$selected" | tr -d '"'
}

# Main
main() {
    local selected_configs
    selected_configs=$(select_configs)

    if [[ -z "$selected_configs" ]]; then
        print_info "No se selecciono ninguna configuracion"
        return 0
    fi

    for config in $selected_configs; do
        case "$config" in
            zshrc)
                edit_config "$TEMPLATES_DIR/zshrc.template" "$HOME/.zshrc" ".zshrc"
                ;;
            bashrc)
                edit_config "$TEMPLATES_DIR/bashrc.template" "$HOME/.bashrc" ".bashrc"
                ;;
            claude)
                copy_claude_config
                ;;
        esac
    done

    print_success "Configuraciones personalizadas"
}

main

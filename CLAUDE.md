# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a personal Ubuntu dotfiles repository for managing development environment configurations. It uses symlinks to manage configuration files, allowing changes to be tracked in git while maintaining files in their expected system locations.

**Critical Path Assumption**: All scripts assume the repository is cloned to `~/projects/dotfiles`. Changing this location requires updating hardcoded paths in scripts.

## Architecture

### Symlink-Based Configuration Management

The core architecture uses symlinks from system config locations to files in this repository:

- `~/.zshrc` → `~/projects/dotfiles/shell/.zshrc`
- `~/.bashrc` → `~/projects/dotfiles/shell/.bashrc`
- `~/.p10k.zsh` → `~/projects/dotfiles/shell/.p10k.zsh`
- `~/.gitconfig` → `~/projects/dotfiles/git/.gitconfig`
- `~/.config/gh` → `~/projects/dotfiles/config/gh`
- `~/.claude/settings.json` → `~/projects/dotfiles/claude/settings.json`

This means editing files in their normal locations (e.g., `~/.zshrc`) automatically updates the repository.

**VSCode Exception**: VSCode configuration is managed via Settings Sync (GitHub account), NOT symlinks. The `vscode/` directory in this repo is for reference only and is not actively used.

### Directory Structure

```
dotfiles/
├── shell/              # Zsh, Bash, Powerlevel10k configs
├── git/                # Git global configuration
├── vscode/             # VSCode settings, keybindings, extensions list
├── config/             # Other ~/.config files (gh CLI, etc.)
├── claude/             # Claude Code settings
├── gnome/              # GNOME desktop settings (dconf dumps)
├── scripts/
│   ├── lib/
│   │   └── common.sh       # Funciones compartidas (colores, helpers)
│   ├── installers/
│   │   ├── system.sh       # Paquetes base del sistema
│   │   ├── shell.sh        # Zsh, Oh My Zsh, plugins
│   │   ├── dev-tools.sh    # NVM, Docker, uv
│   │   ├── cli-tools.sh    # gh, claude, bat, eza, tldr, micro
│   │   ├── apps.sh         # VSCode, Chrome
│   │   └── fonts.sh        # Fira Code Nerd Font
│   ├── setup.sh            # Script principal con menu interactivo
│   ├── setup-git-ssh.sh    # Configuracion Git y SSH
│   ├── setup-gnome.sh      # Configuracion GNOME
│   ├── export-gnome.sh     # Exportar settings GNOME
│   └── apply-theme.sh      # Tema One Dark para terminal
└── install.sh          # Main symlink creation script
```

## Common Commands

### Initial Setup (New System)

**CRITICAL ORDER**: Must run in this exact sequence to avoid Oh My Zsh overwriting the custom .zshrc:

```bash
# 1. Run interactive setup (select components to install)
./scripts/setup.sh

# Or install everything at once:
./scripts/setup.sh --all

# Or install specific components:
./scripts/setup.sh --only system,shell,dev-tools

# 2. Create symlinks - this MUST run AFTER setup.sh
#    to overwrite Oh My Zsh's default .zshrc with the custom one
./install.sh

# 3. Configure GNOME desktop environment
./scripts/setup-gnome.sh

# 4. Log out and back in to apply all changes
```

**Why this order matters**: Oh My Zsh installation creates its own `.zshrc` and renames any existing one to `.zshrc.pre-oh-my-zsh`. Running `install.sh` after ensures the custom `.zshrc` from the repo replaces the default Oh My Zsh one.

### Updating Configurations

```bash
# Export current GNOME settings to repository
./scripts/export-gnome.sh

# Export VSCode extensions list
code --list-extensions > vscode/extensions.txt

# Changes to other configs are automatic via symlinks
```

### Syncing Between Machines

```bash
# On machine A (after making changes)
cd ~/projects/dotfiles
git add .
git commit -m "Update configurations"
git push

# On machine B (to receive changes)
cd ~/projects/dotfiles
git pull
# Changes apply immediately via symlinks
```

## Key Installation Scripts

### install.sh

Creates all symlinks from repository to system locations. Automatically backs up existing files with timestamp before creating symlinks (`.backup.YYYYMMDD_HHMMSS`).

### scripts/setup.sh (Script Principal)

Script principal con menu interactivo para seleccionar componentes a instalar.

**Uso:**
```bash
./scripts/setup.sh              # Menu interactivo
./scripts/setup.sh --all        # Instalar todo
./scripts/setup.sh --only X,Y   # Solo componentes especificos
./scripts/setup.sh --list       # Listar componentes disponibles
```

**Componentes disponibles:**
- `system` - Actualizacion apt + paquetes base (git, curl, build-essential, flatpak)
- `shell` - Zsh, Oh My Zsh, Powerlevel10k, plugins, tema One Dark
- `git-ssh` - Configuracion Git y generacion de SSH key
- `dev-tools` - NVM/Node.js, Docker, uv (Python)
- `cli-tools` - gh, claude, bat, eza, tldr, micro
- `apps` - VSCode + extensiones, Google Chrome
- `fonts` - Fira Code Nerd Font

### scripts/installers/

Directorio con scripts modulares para cada categoria. Pueden ejecutarse individualmente:

```bash
./scripts/installers/shell.sh      # Solo shell
./scripts/installers/dev-tools.sh  # Solo herramientas dev
```

### scripts/setup-git-ssh.sh

Configuracion interactiva de Git y SSH:
- Solicita nombre y email para Git
- Genera SSH key para GitHub
- Muestra la clave publica para agregarla a GitHub

### scripts/apply-theme.sh

Applies the One Dark (247) terminal theme using Gogh:
- Installs dependencies (dconf-cli, uuid-runtime)
- Downloads and applies One Dark theme to GNOME Terminal
- Provides instructions to set as default profile
- Can be run separately if theme wasn't applied during initial setup

### scripts/setup-gnome.sh

Installs GNOME extensions and restores desktop configuration:
- Automatically downloads and installs Dash to Panel from extensions.gnome.org
- Loads dconf settings for Dash to Panel, GNOME Shell, and Desktop
- Enables extensions listed in `gnome/extensions-list.txt`
- **Must be run manually** after cloning repo to apply GNOME settings
- **Requires GNOME Shell restart** (log out/in) to take effect

### scripts/export-gnome.sh

Exports current GNOME configuration to repository:
- Dumps dconf settings for Dash to Panel, GNOME Shell, and Desktop
- Exports list of installed extensions
- Use this before committing GNOME-related changes

**GNOME Configuration Important Note**: Unlike other configs, GNOME settings are stored in dconf (a database), not files. This means:
- Cannot use symlinks for GNOME configuration
- Must run `setup-gnome.sh` manually to apply settings after cloning
- Must run `export-gnome.sh` to save changes back to repo
- Changes don't sync automatically like shell/git configs do

## Important Considerations

### When Adding New Configuration Files

1. Copy the file/directory to appropriate location in repository
2. Edit `install.sh` to add the symlink creation logic
3. Test by running `./install.sh`
4. Commit changes

### When Adding New Installers

1. Create script in `scripts/installers/` siguiendo el patron existente
2. Usar `source "$SCRIPT_DIR/../lib/common.sh"` para funciones comunes
3. Agregar el componente en `scripts/setup.sh` (arrays COMPONENTS e INSTALL_ORDER)
4. Probar ejecutando el instalador individualmente y desde el menu

### Backup System

`install.sh` creates automatic backups before overwriting. Backups are stored as:
- `~/.zshrc.backup.20250314_120000`
- Format: `{original_path}.backup.{timestamp}`

To restore a backup, remove the symlink and rename the backup file.

### Post-Installation Authentication

After running setup scripts, authenticate with:
- `gh auth login` - GitHub CLI
- `claude auth login` - Claude CLI
- `docker login` - Docker Hub (if pushing images)
- Add generated SSH key (`~/.ssh/id_ed25519.pub`) to GitHub settings

### Shell Changes

After installing Zsh/Oh My Zsh, the default shell changes to zsh. Either:
- Log out and back in, or
- Start new terminal session

### Docker Permissions

After Docker installation, user is added to `docker` group. Log out and back in to use Docker without `sudo`.

## Language and Documentation

Repository documentation and comments are in Spanish. The primary user is a Spanish-speaking developer working on Ubuntu-based systems.

# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

Personal Ubuntu dotfiles with an interactive wizard for system configuration. The repository assumes it will be cloned to `~/projects/dotfiles`.

## Commands

```bash
# Run interactive wizard
./scripts/setup.sh

# Install all modules without prompts
./scripts/setup.sh --all

# Install specific modules
./scripts/setup.sh --only system,shell,git

# List available modules
./scripts/setup.sh --list

# Run individual module
./scripts/modules/apps.sh
```

## Architecture

### Two-Level Wizard System

1. **setup.sh** - Main wizard that shows a checklist of modules (system, shell, git, dev, cli, apps, fonts, config)
2. **modules/apps.sh** - Secondary wizard with individual app selection (Chrome, VSCode, Claude, gcloud, etc.)

The wizard uses `whiptail` for TUI with a custom dark theme defined in `common.sh` via `NEWT_COLORS`.

### Module Structure

All modules in `scripts/modules/` follow the same pattern:
```bash
#!/bin/bash
set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"
print_header "Module Name"
# Installation logic using is_installed, file_exists, dir_exists checks
print_success "Done"
```

### Shared Functions (scripts/lib/common.sh)

- `print_header`, `print_step`, `print_success`, `print_warning`, `print_error`, `print_info` - Colored output
- `is_installed`, `dir_exists`, `file_exists` - Check functions
- `install_clipboard` - Auto-detects X11/Wayland and installs xclip or wl-clipboard
- `DOTFILES_DIR` - Base path constant (`$HOME/projects/dotfiles`)

### Config Templates

Shell configs use a template system:
- `shell/zshrc.template` and `shell/bashrc.template` are templates
- Module `config.sh` opens them with `micro` for editing before saving to `~/`
- `claude/settings.json` is copied directly (not edited) with pre-configured permissions

## Language

Documentation, comments, and user-facing messages are in Spanish.

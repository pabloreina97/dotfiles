# Dotfiles Ubuntu

Configuración personal para Ubuntu con wizard interactivo.

## Instalación rápida

```bash
curl -fsSL https://raw.githubusercontent.com/pabloreina97/dotfiles/main/bootstrap.sh | bash
```

O manualmente:

```bash
sudo apt install git -y
git clone https://github.com/pabloreina97/dotfiles ~/projects/dotfiles
cd ~/projects/dotfiles
./scripts/setup.sh
```

## Qué incluye

### Módulos del wizard

| Módulo | Descripción |
|--------|-------------|
| `system` | Actualización apt, paquetes base, clipboard (xclip/wl-clipboard según X11 o Wayland) |
| `shell` | Zsh, Oh My Zsh, Powerlevel10k, plugins, tema One Dark |
| `git` | Configuración Git, SSH key, GitHub CLI auth |
| `dev` | NVM/Node.js, Docker, uv (Python) |
| `cli` | bat, eza, ripgrep, fd, tldr, htop, jq, tree, micro |
| `apps` | Chrome, VSCode, Flameshot, Claude, gcloud (selector individual) |
| `fonts` | Fira Code Nerd Font |
| `config` | Personalizar .zshrc, .bashrc, Claude settings |

### Selector de aplicaciones

El módulo `apps` abre un segundo selector para elegir qué instalar:

- Google Chrome
- Visual Studio Code
- Flameshot (capturas)
- Claude Code CLI
- Google Cloud CLI (+ auth + ADC)
- [Desinstalar] Firefox

## Estructura

```
dotfiles/
├── bootstrap.sh              # Script de inicio rápido
├── scripts/
│   ├── setup.sh              # Wizard principal
│   ├── lib/
│   │   └── common.sh         # Funciones compartidas
│   └── modules/
│       ├── system.sh
│       ├── shell.sh
│       ├── git.sh
│       ├── dev.sh
│       ├── cli.sh
│       ├── apps.sh
│       ├── fonts.sh
│       └── config.sh
├── shell/
│   ├── zshrc.template        # Template para .zshrc
│   ├── bashrc.template       # Template para .bashrc
│   └── .p10k.zsh
├── git/
│   └── .gitconfig
├── claude/
│   └── settings.json         # Config con permissions seguras
└── config/
    └── gh/
        └── config.yml
```

## Uso

### Wizard interactivo

```bash
./scripts/setup.sh
```

### Instalar todo sin preguntar

```bash
./scripts/setup.sh --all
```

### Instalar módulos específicos

```bash
./scripts/setup.sh --only system,shell,git
```

### Ver módulos disponibles

```bash
./scripts/setup.sh --list
```

### Ejecutar módulo individual

```bash
./scripts/modules/apps.sh
```

## Personalización

### Configurar .zshrc

El módulo `config` abre el template con `micro` para que lo edites antes de guardarlo en `~/.zshrc`.

### Claude Code permissions

El archivo `claude/settings.json` tiene permissions preconfiguradas:

- **allow**: Comandos de solo lectura (git status, ls, cat, grep...)
- **ask**: Comandos que modifican o consumen recursos (git push, npm install, rm...)

## Post-instalación

Después del wizard, puede que necesites:

```bash
# Reiniciar terminal para zsh
exec zsh

# Si instalaste Docker, cerrar sesión y volver a entrar
# para aplicar el grupo docker
```

## Requisitos

- Ubuntu 22.04+ o derivados
- Conexión a internet

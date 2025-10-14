# Dotfiles

Configuración personal de Ubuntu para desarrollo. Este repositorio contiene todos mis archivos de configuración y scripts de instalación para replicar rápidamente mi entorno de trabajo.

## Contenido

```
dotfiles/
├── shell/              # Configuración de Zsh y Bash
│   ├── .zshrc         # Configuración de Zsh con Oh My Zsh
│   ├── .bashrc        # Configuración de Bash
│   └── .p10k.zsh      # Configuración de Powerlevel10k
├── git/               # Configuración de Git
│   └── .gitconfig     # Config global de Git
├── vscode/            # Configuración de VSCode
│   ├── settings.json
│   ├── keybindings.json
│   └── extensions.txt
├── config/            # Otras configuraciones (~/.config)
│   └── gh/           # GitHub CLI config
├── claude/            # Configuración de Claude Code
│   └── settings.json  # Settings de Claude Code
├── scripts/           # Scripts de instalación
│   └── setup-packages.sh
└── install.sh         # Script principal de instalación
```

## Instalación Rápida

### En un sistema nuevo

1. **Clonar el repositorio:**
   ```bash
   git clone https://github.com/TU_USUARIO/dotfiles.git ~/projects/dotfiles
   cd ~/projects/dotfiles
   ```

2. **Instalar paquetes y herramientas (incluyendo Oh My Zsh):**
   ```bash
   ./scripts/setup-packages.sh
   ```

3. **Crear symlinks (esto sobrescribe el .zshrc de Oh My Zsh con tu config):**
   ```bash
   ./install.sh
   ```

4. **Configurar GNOME (extensiones y tema):**
   ```bash
   ./scripts/setup-gnome.sh
   ```

5. **Cerrar sesión y volver a entrar** para aplicar todos los cambios

### En un sistema existente (solo actualizar configs)

```bash
./install.sh
```

Esto creará backups automáticos de tus archivos existentes antes de crear los symlinks.

## ¿Qué se instala?

El script `setup-packages.sh` instala:

- **Shell:** Zsh, Oh My Zsh, Powerlevel10k
- **Terminal Theme:** One Dark (247) de Gogh
- **Dev Tools:** Git, Build essentials, curl, wget
- **Node.js:** NVM + Node LTS
- **Python:** uv (gestor de versiones y paquetes)
- **Docker:** Docker Engine + Docker Compose
- **CLI Tools:** GitHub CLI (gh), Claude CLI, bat, eza, tldr, micro
- **Editores:** VSCode + extensiones, micro
- **Browsers:** Google Chrome
- **Fonts:** Fira Code Nerd Font
- **GNOME:** Extension Manager, Dash to Panel, Desktop Icons (DING), Tiling Assistant
- **Cloud:** Google Cloud SDK (opcional, comentado)
- **SSH:** Genera automáticamente SSH key para GitHub

## Estructura de Symlinks

Los symlinks se crean automáticamente:

```
~/.zshrc                  -> ~/projects/dotfiles/shell/.zshrc
~/.bashrc                 -> ~/projects/dotfiles/shell/.bashrc
~/.p10k.zsh               -> ~/projects/dotfiles/shell/.p10k.zsh
~/.gitconfig              -> ~/projects/dotfiles/git/.gitconfig
~/.config/gh              -> ~/projects/dotfiles/config/gh
~/.claude/settings.json   -> ~/projects/dotfiles/claude/settings.json
```

**Notas especiales:**
- **VSCode:** La configuración de VSCode se sincroniza mediante **Settings Sync** con tu cuenta de GitHub, no mediante symlinks. Para activarlo: `Ctrl+Shift+P` -> "Settings Sync: Turn On"
- **Claude Code:** La configuración de Claude Code (`~/.claude/settings.json`) sí usa symlinks para sincronizarse entre máquinas

## Personalización

### Modificar configuraciones

Simplemente edita los archivos en tu sistema. Los cambios se reflejan automáticamente en el repositorio gracias a los symlinks:

```bash
# Editar zshrc
nano ~/.zshrc

# Los cambios están en el repo automáticamente
cd ~/projects/dotfiles
git status
```

### Agregar nuevas configuraciones

1. Copia el archivo/directorio al repo:
   ```bash
   cp ~/.mi_config ~/projects/dotfiles/config/
   ```

2. Edita `install.sh` para agregar el symlink:
   ```bash
   create_symlink "$DOTFILES_DIR/config/.mi_config" "$HOME/.mi_config"
   ```

3. Commit los cambios:
   ```bash
   git add .
   git commit -m "Agregar configuración de mi_config"
   git push
   ```

## Actualizar Configuraciones

### VSCode
VSCode se sincroniza automáticamente con **Settings Sync** (GitHub). La carpeta `vscode/` en este repo es solo referencia y no se usa activamente.

### Configuración de GNOME

**Aplicar configuración guardada:**
```bash
./scripts/setup-gnome.sh
# Luego cierra sesión y vuelve a entrar
```

**Exportar cambios después de modificar GNOME:**
```bash
./scripts/export-gnome.sh
git add gnome/
git commit -m "Actualizar configuración de GNOME"
git push
```

**Nota:** La configuración de GNOME se guarda en dconf (base de datos), no en archivos. Por eso necesitas ejecutar `setup-gnome.sh` manualmente para aplicar los cambios guardados en el repo.

### Tema de Terminal

El script `setup-packages.sh` instala automáticamente el tema **One Dark (247)** de Gogh. Si quieres aplicarlo después:

```bash
./scripts/apply-theme.sh
```

Luego establécelo como predeterminado en **Preferencias de Terminal** → **Perfiles** → selecciona **One Dark** → **Establecer como predeterminado**.

## Restaurar configuración original

Si necesitas volver a tus archivos originales, los backups están en:

```bash
~/.zshrc.backup.YYYYMMDD_HHMMSS
~/.gitconfig.backup.YYYYMMDD_HHMMSS
# etc...
```

Para restaurar:

```bash
# Eliminar symlink
rm ~/.zshrc

# Restaurar backup
mv ~/.zshrc.backup.YYYYMMDD_HHMMSS ~/.zshrc
```

## Herramientas CLI Modernas

El script instala varias herramientas CLI modernas que mejoran la experiencia en la terminal:

- **bat** (`batcat`): Reemplazo de `cat` con syntax highlighting y paginación
  ```bash
  bat archivo.py        # Ver archivo con colores
  ```

- **eza**: Reemplazo moderno de `ls` con íconos y colores
  ```bash
  eza -la              # Listar con detalles
  eza --tree           # Vista en árbol
  ```

- **tldr**: Páginas de ayuda simplificadas (más fácil que `man`)
  ```bash
  tldr tar             # Ver ejemplos rápidos de tar
  ```

- **micro**: Editor de texto terminal intuitivo (alternativa a nano/vim)
  ```bash
  micro archivo.txt    # Editar con atajos familiares (Ctrl+S, Ctrl+Q)
  ```

- **uv**: Gestor ultrarrápido de versiones y paquetes de Python
  ```bash
  uv python install 3.12    # Instalar Python 3.12
  uv venv                   # Crear entorno virtual
  uv pip install requests   # Instalar paquetes
  ```

## Autenticación de Servicios

Después de ejecutar `setup-packages.sh`, necesitas autenticarte en los servicios:

### GitHub
```bash
# Autenticar GitHub CLI
gh auth login

# Tu SSH key ya fue generada y está en:
cat ~/.ssh/id_ed25519.pub

# Agrégala a GitHub en:
# https://github.com/settings/keys
```

### Claude
```bash
claude auth login
```

### Google Cloud (si lo instalaste)
```bash
gcloud auth login
gcloud config set project TU_PROYECTO
```

### Docker Hub (si necesitas push)
```bash
docker login
```

## Notas Importantes

- **Backups automáticos:** `install.sh` crea backups de archivos existentes antes de crear symlinks
- **Ruta del repo:** Los scripts asumen que el repo está en `~/projects/dotfiles`
- **Git config:** La primera vez, `setup-packages.sh` te pedirá tu nombre y email para Git
- **SSH key:** Se genera automáticamente una clave ED25519 para GitHub
- **Docker:** Después de instalar Docker, cierra sesión y vuelve a entrar para usarlo sin sudo

## Sincronización entre máquinas

1. **Hacer cambios en máquina A:**
   ```bash
   # Editas archivos normalmente
   nano ~/.zshrc

   # Commit y push
   cd ~/projects/dotfiles
   git add .
   git commit -m "Actualizar zshrc"
   git push
   ```

2. **Actualizar máquina B:**
   ```bash
   cd ~/projects/dotfiles
   git pull
   # Los cambios se aplican automáticamente por los symlinks!
   ```

## Requisitos

- Ubuntu 20.04 o superior
- Conexión a internet
- Privilegios sudo

## Soporte

Si encuentras problemas o tienes sugerencias, abre un issue en el repositorio.

## Licencia

MIT

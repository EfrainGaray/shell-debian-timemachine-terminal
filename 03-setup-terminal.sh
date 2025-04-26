#!/usr/bin/env bash
set -euo pipefail

# -----------------------------------------------
# 03-setup-terminal.sh
# Instalación de Alacritty + configuración visual
# -----------------------------------------------

# Variables
USER_NAME="xian"
USER_HOME="/home/${USER_NAME}"
ALACRITTY_CONFIG_DIR="${USER_HOME}/.config/alacritty"
ALACRITTY_CONFIG_FILE="${ALACRITTY_CONFIG_DIR}/alacritty.yml"
FONT_NAME="Hack Nerd Font"

# Función para hacer backup si existe
backup_file() {
    local file=$1
    if [ -f "$file" ]; then
        mkdir -p "${USER_HOME}/backups-starterkit"
        timestamp=$(date +"%Y%m%d-%H%M%S")
        cp "$file" "${USER_HOME}/backups-starterkit/$(basename $file).$timestamp.bak" || true
        echo "📦 Backup realizado de $file"
    fi
}

# 1. Verificación de root
if [ "$(id -u)" -ne 0 ]; then
    echo "❌ Este script debe ejecutarse como root."
    exit 1
fi

# 2. Instalación de Alacritty
echo "🖥️ Instalando Alacritty..."
if ! command -v alacritty &>/dev/null; then
    apt install -y alacritty || {
        echo "⚠️ Alacritty no disponible en repositorios. Compilando..."
        apt install -y cmake pkg-config libfreetype6-dev libfontconfig1-dev libxcb-xfixes0-dev python3
        git clone https://github.com/alacritty/alacritty.git /tmp/alacritty
        cd /tmp/alacritty
        cargo build --release
        cp target/release/alacritty /usr/local/bin
    }
fi

# 3. Crear configuración de Alacritty
echo "⚙️ Configurando Alacritty..."
mkdir -p "${ALACRITTY_CONFIG_DIR}"
backup_file "${ALACRITTY_CONFIG_FILE}"

cat > "${ALACRITTY_CONFIG_FILE}" <<EOF
window:
  padding:
    x: 8
    y: 8
  dynamic_padding: true
  opacity: 0.95

font:
  normal:
    family: "${FONT_NAME}"
    style: Regular
  bold:
    family: "${FONT_NAME}"
    style: Bold
  italic:
    family: "${FONT_NAME}"
    style: Italic
  size: 11.0

colors:
  primary:
    background: '0x282828'
    foreground: '0xebdbb2'

  normal:
    black:   '0x282828'
    red:     '0xcc241d'
    green:   '0x98971a'
    yellow:  '0xd79921'
    blue:    '0x458588'
    magenta: '0xb16286'
    cyan:    '0x689d6a'
    white:   '0xa89984'

  bright:
    black:   '0x928374'
    red:     '0xfb4934'
    green:   '0xb8bb26'
    yellow:  '0xfabd2f'
    blue:    '0x83a598'
    magenta: '0xd3869b'
    cyan:    '0x8ec07c'
    white:   '0xebdbb2'
EOF

# 4. Permisos correctos
chown -R "${USER_NAME}:${USER_NAME}" "${ALACRITTY_CONFIG_DIR}"

# 5. Crear alias para lanzar Alacritty
echo "🔗 Agregando alias 'term'..."
echo "alias term='alacritty'" >> "${USER_HOME}/.zshrc"
echo "alias term='alacritty'" >> /root/.zshrc

# 6. Mensaje final
echo "✅ Alacritty instalado y configurado exitosamente."

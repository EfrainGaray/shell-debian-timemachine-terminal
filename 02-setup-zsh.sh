#!/usr/bin/env bash
set -euo pipefail

# -----------------------------------------------
# 02-setup-zsh.sh
# Instalación avanzada de ZSH + Oh-My-Zsh + Powerlevel10k
# -----------------------------------------------

# Variables
USER_NAME="xian"
USER_HOME="/home/${USER_NAME}"
ZSH_CUSTOM="${USER_HOME}/.oh-my-zsh/custom"

# Función para hacer backup de archivos si existen
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

# 2. Instalar ZSH
echo "🐚 Instalando ZSH..."
apt install -y zsh

# 3. Backup y eliminación de configuraciones antiguas
echo "📦 Realizando backup de configuraciones ZSH anteriores..."
backup_file "${USER_HOME}/.zshrc"
backup_file "/root/.zshrc"

echo "🧹 Eliminando configuraciones viejas..."
rm -rf "${USER_HOME}/.oh-my-zsh" || true
rm -rf "/root/.oh-my-zsh" || true

# 4. Instalar Oh-My-Zsh para xian
echo "💻 Instalando Oh-My-Zsh para ${USER_NAME}..."
sudo -u "${USER_NAME}" sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

# 5. Instalar Oh-My-Zsh para root
echo "💻 Instalando Oh-My-Zsh para root..."
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

# 6. Instalar plugins
echo "🔌 Instalando plugins ZSH..."
sudo -u "${USER_NAME}" git clone https://github.com/zsh-users/zsh-autosuggestions "${ZSH_CUSTOM}/plugins/zsh-autosuggestions"
sudo -u "${USER_NAME}" git clone https://github.com/zsh-users/zsh-syntax-highlighting "${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting"
sudo -u "${USER_NAME}" git clone https://github.com/Aloxaf/fzf-tab "${ZSH_CUSTOM}/plugins/fzf-tab"

# 7. Instalar tema Powerlevel10k
echo "🎨 Instalando tema Powerlevel10k..."
sudo -u "${USER_NAME}" git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM}/themes/powerlevel10k"

# 8. Configurar .zshrc para usuario xian
echo "⚙️ Configurando .zshrc para ${USER_NAME}..."
cat > "${USER_HOME}/.zshrc" <<'EOF'
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"
plugins=(
  git
  zsh-autosuggestions
  zsh-syntax-highlighting
  fzf-tab
)

source $ZSH/oh-my-zsh.sh

# Aliases productivos
alias ll='lsd -l'
alias la='lsd -la'
alias cat='bat'
alias grep='rg'
alias top='btop'
alias g='lazygit'
alias term='alacritty'

# Source Powerlevel10k instant prompt (si existe)
[[ -r "${HOME}/.p10k.zsh" ]] && source "${HOME}/.p10k.zsh"
EOF

# Asegurar permisos correctos
chown "${USER_NAME}:${USER_NAME}" "${USER_HOME}/.zshrc"

# 9. Configurar .zshrc para root (similar)
echo "⚙️ Configurando .zshrc para root..."
cat > /root/.zshrc <<'EOF'
export ZSH="/root/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"
plugins=(
  git
  zsh-autosuggestions
  zsh-syntax-highlighting
  fzf-tab
)

source $ZSH/oh-my-zsh.sh

alias ll='lsd -l'
alias la='lsd -la'
alias cat='bat'
alias grep='rg'
alias top='btop'
alias g='lazygit'
alias term='alacritty'

[[ -r "/root/.p10k.zsh" ]] && source "/root/.p10k.zsh"
EOF

# 10. Cambiar shell por defecto a ZSH para xian y root
echo "🔄 Cambiando shell predeterminada a ZSH..."
chsh -s "$(which zsh)" "${USER_NAME}"
chsh -s "$(which zsh)" root

echo "✅ ZSH configurado exitosamente para ${USER_NAME} y root."

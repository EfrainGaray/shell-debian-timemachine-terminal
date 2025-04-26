#!/usr/bin/env bash
set -euo pipefail

# -----------------------------------------------
# 05-setup-tools.sh
# Instalación de herramientas visuales modernas
# -----------------------------------------------

# Variables
USER_NAME="xian"
USER_HOME="/home/${USER_NAME}"

# Lista de herramientas a instalar
TOOLS=(
    btop
    bat
    lsd
    exa
    htop
    neofetch
    glances
    ripgrep
    fzf
    lazygit
)

# Función para instalar una herramienta si no existe
install_tool() {
    local tool=$1
    if ! command -v "$tool" &>/dev/null; then
        echo "📦 Instalando ${tool}..."
        apt install -y "$tool" || echo "⚠️ Falló instalación de ${tool}, verificando si requiere método alternativo..."
    else
        echo "✅ ${tool} ya instalado."
    fi
}

# 1. Verificación de root
if [ "$(id -u)" -ne 0 ]; then
    echo "❌ Este script debe ejecutarse como root."
    exit 1
fi

# 2. Actualizar APT
echo "🔄 Actualizando repositorios..."
apt update

# 3. Instalar herramientas
echo "🛠️ Instalando herramientas visuales..."
for tool in "${TOOLS[@]}"; do
    install_tool "$tool"
done

# 4. Correcciones de paquetes
echo "🔧 Ajustando nombres de comandos donde aplica..."
# bat es "batcat" en Debian, creamos alias "bat"
if command -v batcat &>/dev/null && ! command -v bat &>/dev/null; then
    ln -s "$(command -v batcat)" /usr/local/bin/bat
    echo "✅ Alias bat → batcat creado."
fi

# lazygit no siempre está en APT, instalar desde GitHub si falta
if ! command -v lazygit &>/dev/null; then
    echo "⬇️ Instalando LazyGit manualmente..."
    curl -Lo /tmp/lazygit.tar.gz https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_0.41.0_Linux_x86_64.tar.gz
    tar xf /tmp/lazygit.tar.gz -C /usr/local/bin lazygit
    rm /tmp/lazygit.tar.gz
fi

# 5. Configurar alias en ZSH
echo "🔗 Agregando alias a .zshrc..."
{
    echo ""
    echo "# StarterKit aliases"
    echo "alias ll='lsd -l'"
    echo "alias la='lsd -la'"
    echo "alias cat='bat'"
    echo "alias grep='rg'"
    echo "alias top='btop'"
    echo "alias g='lazygit'"
    echo "alias term='alacritty'"
} >> "${USER_HOME}/.zshrc"

{
    echo ""
    echo "# StarterKit aliases"
    echo "alias ll='lsd -l'"
    echo "alias la='lsd -la'"
    echo "alias cat='bat'"
    echo "alias grep='rg'"
    echo "alias top='btop'"
    echo "alias g='lazygit'"
    echo "alias term='alacritty'"
} >> /root/.zshrc

# Asegurar permisos
chown "${USER_NAME}:${USER_NAME}" "${USER_HOME}/.zshrc"

# 6. Mensaje final
echo "✅ Herramientas modernas instaladas y alias configurados."

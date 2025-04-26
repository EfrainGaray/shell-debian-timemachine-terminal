#!/usr/bin/env bash
set -euo pipefail

# -----------------------------------------------
# 08-verify-integrity.sh
# Verificación completa StarterKit (binarios, servicios, configuraciones)
# -----------------------------------------------

# Variables
USER_NAME="xian"
INTEGRITY_REPORT="./starterkit/integrity-report.txt"
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Inicializar reporte
mkdir -p starterkit
echo "# 📋 StarterKit Integrity Report" > "$INTEGRITY_REPORT"
echo "" >> "$INTEGRITY_REPORT"

# Funciones colorizadas
ok() { echo -e "${GREEN}✅ $1${NC}"; echo "✅ $1" >> "$INTEGRITY_REPORT"; }
warn() { echo -e "${YELLOW}⚠️ $1${NC}"; echo "⚠️ $1" >> "$INTEGRITY_REPORT"; }
error() { echo -e "${RED}❌ $1${NC}"; echo "❌ $1" >> "$INTEGRITY_REPORT"; }

# Verificar herramientas disponibles
echo "🔹 Verificando herramientas (binarios + paquetes)..."

TOOLS=(
    git
    make
    gcc
    docker
    bat
    lsd
    exa
    btop
    nmap
    wireshark
    sqlmap
    lazygit
    brave-browser
)

for tool in "${TOOLS[@]}"; do
    if command -v "$tool" &>/dev/null; then
        version=$("$tool" --version 2>/dev/null || true)
        ok "Binario disponible: $tool ${version:-}"
    else
        if dpkg -l | grep -q "$tool"; then
            warn "Binario no encontrado, pero paquete $tool está instalado vía APT."
        else
            error "Herramienta FALTANTE: $tool (no binario ni paquete)"
        fi
    fi
done

echo "" >> "$INTEGRITY_REPORT"

# Verificar servicios activos
echo "🔹 Verificando servicios..."
if systemctl is-active --quiet docker; then
    ok "Servicio Docker activo."
else
    error "Servicio Docker NO activo."
fi

# Verificar grupo docker
if id "$USER_NAME" | grep -q "docker"; then
    ok "Usuario $USER_NAME pertenece al grupo docker."
else
    error "Usuario $USER_NAME NO pertenece al grupo docker."
fi

echo "" >> "$INTEGRITY_REPORT"

# Verificar shells predeterminadas
echo "🔹 Verificando shell predeterminada..."
SHELL_USER=$(getent passwd "$USER_NAME" | cut -d: -f7)
SHELL_ROOT=$(getent passwd root | cut -d: -f7)

[ "$SHELL_USER" == "/usr/bin/zsh" ] && ok "Shell predeterminada de $USER_NAME: ZSH" || error "Shell NO es ZSH para $USER_NAME"
[ "$SHELL_ROOT" == "/usr/bin/zsh" ] && ok "Shell predeterminada de root: ZSH" || error "Shell NO es ZSH para root"

echo "" >> "$INTEGRITY_REPORT"

# Verificar Oh-My-Zsh y Powerlevel10k
echo "🔹 Verificando Oh-My-Zsh y Powerlevel10k..."

for user_home in "/home/${USER_NAME}" "/root"; do
    if [ -d "${user_home}/.oh-my-zsh" ]; then
        ok "Oh-My-Zsh instalado en ${user_home}"
    else
        error "Oh-My-Zsh FALTANTE en ${user_home}"
    fi

    if [ -d "${user_home}/.oh-my-zsh/custom/themes/powerlevel10k" ]; then
        ok "Powerlevel10k instalado en ${user_home}"
    else
        error "Powerlevel10k FALTANTE en ${user_home}"
    fi
done

echo "" >> "$INTEGRITY_REPORT"

# Verificar instalación real de NVM y Node.js
echo "🔹 Verificando NVM y Node.js instalados y operativos..."

verify_node() {
    local user=$1
    local home=$2

    if [ "$user" == "root" ]; then
        export NVM_DIR="/root/.nvm"
        [ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"
        if command -v node &>/dev/null; then
            NODE_VERSION=$(node --version)
            if [[ "$NODE_VERSION" == v20* ]]; then
                ok "Node.js $NODE_VERSION funcionando correctamente para root"
            else
                error "Node.js no está en versión 20.x para root (actual: $NODE_VERSION)"
            fi
        else
            error "Node.js NO encontrado para root"
        fi
    else
        sudo -u "$user" bash -c '
            export NVM_DIR="$HOME/.nvm"
            [ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"
            if command -v node &>/dev/null; then
                NODE_VERSION=$(node --version)
                if [[ "$NODE_VERSION" == v20* ]]; then
                    echo "OK_NODE"
                else
                    echo "BAD_NODE:$NODE_VERSION"
                fi
            else
                echo "NO_NODE"
            fi
        ' > /tmp/node_check_result

        result=$(cat /tmp/node_check_result)
        if [[ "$result" == "OK_NODE" ]]; then
            ok "Node.js v20 funcionando correctamente para $user"
        elif [[ "$result" == NO_NODE ]]; then
            error "Node.js NO encontrado para $user"
        else
            version=$(echo "$result" | cut -d':' -f2)
            error "Node.js no está en versión 20.x para $user (actual: $version)"
        fi
        rm -f /tmp/node_check_result
    fi
}

verify_node "$USER_NAME" "/home/${USER_NAME}"
verify_node "root" "/root"

echo "" >> "$INTEGRITY_REPORT"

# Verificar Nerd Fonts
echo "🔹 Verificando Nerd Fonts instaladas..."
if fc-list | grep -i "Hack Nerd Font" &>/dev/null; then
    ok "Hack Nerd Font disponible"
else
    error "Hack Nerd Font FALTANTE"
fi

echo "" >> "$INTEGRITY_REPORT"

# Verificar contenido de .zshrc
echo "🔹 Verificando configuraciones en .zshrc..."

check_zshrc() {
    local zshrc_path=$1
    if grep -q "powerlevel10k" "$zshrc_path"; then
        ok "Powerlevel10k configurado en $zshrc_path"
    else
        error "Powerlevel10k NO configurado en $zshrc_path"
    fi

    if grep -q "zsh-autosuggestions" "$zshrc_path" && grep -q "zsh-syntax-highlighting" "$zshrc_path" && grep -q "fzf-tab" "$zshrc_path"; then
        ok "Plugins ZSH configurados en $zshrc_path"
    else
        error "Plugins ZSH FALTANTES en $zshrc_path"
    fi

    if grep -q "export NVM_DIR=" "$zshrc_path"; then
        ok "Carga de NVM configurada en $zshrc_path"
    else
        error "NVM NO configurado en $zshrc_path"
    fi
}

check_zshrc "/home/${USER_NAME}/.zshrc"
check_zshrc "/root/.zshrc"

echo "" >> "$INTEGRITY_REPORT"

# Verificar permisos de archivos críticos
echo "🔹 Verificando permisos de configuraciones..."

check_permissions() {
    local file=$1
    local owner=$2
    if [ "$(stat -c %U "$file")" == "$owner" ]; then
        ok "Permisos correctos: $file pertenece a $owner"
    else
        error "Permisos incorrectos: $file no pertenece a $owner"
    fi
}

check_permissions "/home/${USER_NAME}/.zshrc" "$USER_NAME"
check_permissions "/root/.zshrc" "root"

echo "" >> "$INTEGRITY_REPORT"

# Final
echo ""
echo -e "${GREEN}✅ Verificación completa. Reporte generado en: $INTEGRITY_REPORT${NC}"


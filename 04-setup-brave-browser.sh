#!/usr/bin/env bash
set -euo pipefail

# -----------------------------------------------
# 04-setup-brave-browser.sh
# Instalación de Brave Browser desde repositorio oficial
# -----------------------------------------------

# 1. Verificación de root
if [ "$(id -u)" -ne 0 ]; then
    echo "❌ Este script debe ejecutarse como root."
    exit 1
fi

# 2. Verificar si Brave ya está instalado
if command -v brave-browser &>/dev/null; then
    echo "✅ Brave Browser ya está instalado: $(brave-browser --version)"
    exit 0
fi

# 3. Instalar requisitos previos
echo "📦 Instalando requisitos previos..."
apt install -y curl gnupg apt-transport-https

# 4. Agregar clave GPG de Brave
echo "🔐 Agregando clave GPG de Brave..."
curl -fsSL https://brave-browser-apt-release.s3.brave.com/brave-core.asc | gpg --dearmor | tee /usr/share/keyrings/brave-browser-archive-keyring.gpg >/dev/null

# 5. Agregar repositorio Brave
echo "➕ Agregando repositorio de Brave..."
echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg arch=amd64] https://brave-browser-apt-release.s3.brave.com/ stable main" > /etc/apt/sources.list.d/brave-browser-release.list

# 6. Actualizar APT
echo "🔄 Actualizando paquetes..."
apt update

# 7. Instalar Brave Browser
echo "🦁 Instalando Brave Browser..."
apt install -y brave-browser

# 8. Confirmar instalación
echo "✅ Brave Browser instalado: $(brave-browser --version)"

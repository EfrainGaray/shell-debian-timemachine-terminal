#!/usr/bin/env bash
set -euo pipefail

# -----------------------------------------------
# 01-setup-base.sh
# Configuración base para Debian 12
# -----------------------------------------------

# Variables
USER_NAME="xian"
BACKUP_DIR="/home/${USER_NAME}/backups-starterkit"
ROOT_BACKUP_DIR="/root/backups-starterkit"
FONT_DIR="/usr/share/fonts/nerd-fonts"
NERD_FONT_URL="https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/Hack.zip"
NERD_FONT_NAME="Hack"

# Función para hacer backup de archivos si existen
backup_file() {
    local file=$1
    if [ -f "$file" ]; then
        mkdir -p "$BACKUP_DIR"
        mkdir -p "$ROOT_BACKUP_DIR"
        timestamp=$(date +"%Y%m%d-%H%M%S")
        cp "$file" "$BACKUP_DIR/$(basename $file).$timestamp.bak" || true
        cp "$file" "$ROOT_BACKUP_DIR/$(basename $file).$timestamp.bak" || true
        echo "📦 Backup realizado de $file"
    fi
}

# 1. Verificación de root
if [ "$(id -u)" -ne 0 ]; then
    echo "❌ Este script debe ejecutarse como root."
    exit 1
fi

# 2. Verificar conexión a internet
echo "🌐 Verificando conexión a internet..."
if ! ping -c 1 debian.org &>/dev/null; then
    echo "❌ No hay conexión a internet."
    exit 1
fi
echo "✅ Internet activo."

# 3. Actualizar sistema
echo "🔄 Actualizando sistema..."
apt update && apt upgrade -y

# 4. Instalar paquetes esenciales
echo "📦 Instalando paquetes esenciales..."
apt install -y sudo curl wget ca-certificates gnupg git unzip

# 5. Asegurar que el usuario esté en el grupo sudo
echo "🛡️ Asegurando que '${USER_NAME}' tenga acceso sudo..."
if id "$USER_NAME" &>/dev/null; then
    usermod -aG sudo "$USER_NAME"
else
    echo "❌ Usuario ${USER_NAME} no existe."
    exit 1
fi

# 6. Backup de archivos de configuración comunes
echo "📦 Realizando backup de configuraciones anteriores..."
backup_file "/home/${USER_NAME}/.bashrc"
backup_file "/home/${USER_NAME}/.zshrc"
backup_file "/home/${USER_NAME}/.profile"
backup_file "/root/.bashrc"
backup_file "/root/.zshrc"
backup_file "/root/.profile"

# 7. Instalar Nerd Fonts
echo "🔤 Instalando Nerd Fonts (${NERD_FONT_NAME})..."
mkdir -p "$FONT_DIR"
wget -q --show-progress "$NERD_FONT_URL" -O /tmp/${NERD_FONT_NAME}.zip
unzip -o /tmp/${NERD_FONT_NAME}.zip -d "$FONT_DIR"
rm /tmp/${NERD_FONT_NAME}.zip
fc-cache -fv
echo "✅ Nerd Fonts instaladas."

# 8. Limpiar caché
echo "🧹 Limpiando sistema..."
apt autoremove -y
apt autoclean -y

# 9. Crear mensaje MOTD
echo "🖋️ Creando mensaje de bienvenida MOTD..."
cat > /etc/motd <<'EOF'

    🚀 Bienvenido a ANDREA - Debian 12 StarterKit 🚀

    Usuario: xian
    Sistema preparado para programación, hacking y desarrollo.

    StarterKit por Efra 🤘

EOF

echo "✅ StarterKit Base completado exitosamente."


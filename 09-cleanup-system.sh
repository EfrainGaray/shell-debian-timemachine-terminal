#!/usr/bin/env bash
set -euo pipefail

# -----------------------------------------------
# 09-cleanup-system.sh
# Recolector de basura + Fix terminal predeterminada
# -----------------------------------------------

# Variables
CLEANUP_LOG="./starterkit/cleanup-log.txt"
USER_NAME="xian"
USER_HOME="/home/${USER_NAME}"
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Inicializar log
mkdir -p starterkit
echo "# 🧹 Cleanup Report StarterKit" > "$CLEANUP_LOG"
echo "" >> "$CLEANUP_LOG"

# Funciones para mostrar estado
ok() { echo -e "${GREEN}✅ $1${NC}"; echo "✅ $1" >> "$CLEANUP_LOG"; }
error() { echo -e "${RED}❌ $1${NC}"; echo "❌ $1" >> "$CLEANUP_LOG"; }
warn() { echo -e "${YELLOW}⚠️ $1${NC}"; echo "⚠️ $1" >> "$CLEANUP_LOG"; }

# Lista de paquetes a purgar
PACKAGES_TO_PURGE=(
    parole
    ristretto
    orage
    xfburn
    atril
    gigolo
    pidgin
    simple-scan
    gufw
    xfce4-screenshooter
    transmission-gtk
    transmission-common
    gnome-disk-utility
    remmina
    libreoffice-base
    libreoffice-calc
    libreoffice-common
    libreoffice-core
    libreoffice-draw
    libreoffice-gtk3
    libreoffice-impress
    libreoffice-math
    libreoffice-qt5
    libreoffice-writer
    thunderbird
    firefox-esr
    firefox
    xfce4-terminal
)

echo "🔹 Iniciando limpieza de paquetes innecesarios..."

# Función para purgar paquetes
purge_package() {
    local pkg=$1
    if dpkg -l | grep -q "^ii  $pkg "; then
        echo "🗑️ Eliminando $pkg..."
        apt purge -y "$pkg" && ok "Paquete eliminado: $pkg" || error "Fallo al eliminar: $pkg"
    else
        echo "ℹ️ Paquete no encontrado o ya eliminado: $pkg"
    fi
}

# 1. Purgar paquetes
for pkg in "${PACKAGES_TO_PURGE[@]}"; do
    purge_package "$pkg"
done

# 2. Autoremove dependencias huérfanas
echo "🧹 Ejecutando autoremove de paquetes huérfanos..."
apt autoremove -y && ok "Autoremove completado." || error "Fallo en autoremove."

# 3. Limpiar caché de APT
echo "🧹 Limpiando caché de APT..."
apt clean && ok "APT clean completado." || error "Fallo en apt clean."

# 4. Programar fix automático para terminal por defecto
echo "🎯 Programando fix de terminal para primer login gráfico..."

mkdir -p "${USER_HOME}/.config/autostart"
mkdir -p "${USER_HOME}/starterkit"   # <--- FIX agregado aquí ✅

# Crear el archivo .desktop que ejecutará el fix
cat > "${USER_HOME}/.config/autostart/fix-terminal.desktop" <<EOF
[Desktop Entry]
Type=Application
Exec=/home/${USER_NAME}/starterkit/fix-terminal.sh
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
Name=Fix Terminal Default
Comment=Auto-configurar Alacritty como terminal por defecto
EOF

# Crear el script que realiza la configuración real
cat > "${USER_HOME}/starterkit/fix-terminal.sh" <<'EOL'
#!/usr/bin/env bash
set -e
sleep 5
xfconf-query --channel xfce4-session --property /general/DefaultTerminal --create --type string --set alacritty
rm -f ~/.config/autostart/fix-terminal.desktop
rm -f ~/starterkit/fix-terminal.sh
EOL

# Dar permisos correctos
chmod +x "${USER_HOME}/starterkit/fix-terminal.sh"
chown "${USER_NAME}:${USER_NAME}" "${USER_HOME}/.config/autostart/fix-terminal.desktop"
chown "${USER_NAME}:${USER_NAME}" "${USER_HOME}/starterkit/fix-terminal.sh"

ok "Autostart configurado: Alacritty será terminal predeterminada después del primer login XFCE."

# Final
echo ""
echo -e "${GREEN}✅ Limpieza y programación de fix completa. Consulta el log en $CLEANUP_LOG${NC}"
echo ""
echo -e "${RED}⚡ RECOMENDACIÓN: Reiniciar el sistema ahora.${NC}"


#!/usr/bin/env bash
set -euo pipefail

# -----------------------------------------------
# 07-setup-hacking-pack.sh
# Instalación de herramientas clásicas de hacking ofensivo
# -----------------------------------------------

# Función para instalar una herramienta si no existe
install_tool() {
    local tool=$1
    if ! command -v "$tool" &>/dev/null; then
        echo "📦 Instalando ${tool}..."
        apt install -y "$tool"
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

# 3. Herramientas de hacking a instalar
HACKING_TOOLS=(
    nmap
    wireshark
    john
    hashcat
    hydra
    sqlmap
    aircrack-ng
    tcpdump
    nikto
    gobuster
    dirb
)

# 4. Instalar herramientas
echo "🛠️ Instalando herramientas de hacking..."
for tool in "${HACKING_TOOLS[@]}"; do
    install_tool "$tool"
done

# 5. Post-instalación: No levantar servicios automáticos
echo "🔒 Asegurando que Wireshark no active servicios por defecto..."
DEBIAN_FRONTEND=noninteractive apt install -y wireshark-common || true

# 6. Confirmaciones finales
echo "🔎 Herramientas instaladas:"
for tool in "${HACKING_TOOLS[@]}"; do
    if command -v "$tool" &>/dev/null; then
        echo "✅ $tool listo para usar."
    else
        echo "⚠️ $tool no disponible en sistema (revisar manualmente si es crítico)."
    fi
done

echo "✅ Pack de hacking instalado exitosamente."

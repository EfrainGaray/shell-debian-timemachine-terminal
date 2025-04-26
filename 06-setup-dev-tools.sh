#!/usr/bin/env bash
set -euo pipefail

# -----------------------------------------------
# 06-setup-dev-tools.sh
# Instalación del stack de herramientas de desarrollo
# -----------------------------------------------

# Variables
USER_NAME="xian"
USER_HOME="/home/${USER_NAME}"

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

# 2. Actualizar repositorios
echo "🔄 Actualizando repositorios..."
apt update

# 3. Instalar herramientas esenciales
echo "🛠️ Instalando herramientas de desarrollo..."
ESSENTIAL_TOOLS=(
    git
    make
    build-essential
    jq
    yq
    python3-pip
)

for tool in "${ESSENTIAL_TOOLS[@]}"; do
    install_tool "$tool"
done

# 4. Instalación de Node.js + npm (versión estable recomendada)
echo "🧩 Instalando Node.js + npm..."
if ! command -v node &>/dev/null; then
    curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
    apt install -y nodejs
fi

# 5. Instalación de Docker
echo "🐳 Instalando Docker y Docker Compose..."
apt install -y docker.io docker-compose-plugin

# 6. Agregar usuario xian al grupo docker
echo "👤 Agregando usuario ${USER_NAME} al grupo docker..."
usermod -aG docker "$USER_NAME"

# 7. Habilitar e iniciar servicio Docker
echo "🔌 Activando servicio Docker..."
systemctl enable docker
systemctl start docker

# 8. Confirmaciones
echo "🔎 Versiones instaladas:"
git --version
make --version
gcc --version
node --version
npm --version
docker --version
docker compose version
python3 --version
pip3 --version
jq --version
yq --version

echo "✅ Stack de herramientas de desarrollo instalado exitosamente."

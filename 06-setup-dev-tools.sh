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

# 4. Instalación de NVM (Node Version Manager)
echo "📦 Instalando NVM (Node Version Manager)..."

# Para usuario xian
export NVM_DIR="/home/${USER_NAME}/.nvm"
sudo -u "${USER_NAME}" bash -c "
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
"

# Para root
export NVM_DIR="/root/.nvm"
bash -c "
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
"

# Agregar carga automática de NVM en ZSH para xian
echo "🔗 Configurando carga automática de NVM en ZSH..."
echo '
# NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
' >> "/home/${USER_NAME}/.zshrc"

# Para root
echo '
# NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
' >> "/root/.zshrc"

# Asegurar permisos correctos
chown "${USER_NAME}:${USER_NAME}" "/home/${USER_NAME}/.zshrc"

# 5. Instalar Node.js 20 usando NVM
echo "🧩 Instalando Node.js 20 usando NVM..."

# Para xian
sudo -u "${USER_NAME}" bash -c '
  export NVM_DIR="$HOME/.nvm"
  source "$NVM_DIR/nvm.sh"
  nvm install 20
  nvm alias default 20
'

# Para root
bash -c '
  export NVM_DIR="/root/.nvm"
  source "$NVM_DIR/nvm.sh"
  nvm install 20
  nvm alias default 20
'

# 6. Instalación de Docker y Docker Compose correctamente
echo "🐳 Instalando Docker Engine y Docker Compose Plugin desde repositorio oficial..."

# Eliminar cualquier versión vieja
apt remove -y docker docker-engine docker.io containerd runc || true

# Instalar paquetes de requerimiento
apt install -y ca-certificates curl gnupg lsb-release

# Agregar clave oficial de Docker
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg

# Agregar repositorio oficial de Docker
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
  $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

# Actualizar repositorios
apt update

# Instalar Docker y Docker Compose
apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# 7. Agregar usuario xian al grupo docker
echo "👤 Agregando usuario ${USER_NAME} al grupo docker..."
usermod -aG docker "$USER_NAME"

# 8. Habilitar e iniciar servicio Docker
echo "🔌 Activando servicio Docker..."
systemctl enable docker
systemctl start docker

# 9. Confirmaciones finales
echo "🔎 Versiones instaladas:"
git --version
make --version
gcc --version
sudo -u "${USER_NAME}" bash -c 'source $HOME/.nvm/nvm.sh && node --version'
sudo -u "${USER_NAME}" bash -c 'source $HOME/.nvm/nvm.sh && npm --version'
docker --version
docker compose version
python3 --version
pip3 --version
jq --version
yq --version

echo "✅ Stack de herramientas de desarrollo instalado exitosamente."


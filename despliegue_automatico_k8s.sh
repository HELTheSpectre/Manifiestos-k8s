#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

# ==============================
# despliegue_automatico_k8s.sh
# Trabajo 0311AT - Computación en la Nube
# Autor: Giuliano Moro
# ==============================

# Función para verificar herramientas necesarias
check_command() {
  command -v "$1" &>/dev/null || {
    echo "Error: '$1' no está instalado o en el PATH"
    exit 1
  }
}

echo "Verificando herramientas necesarias..."
for cmd in git kubectl minikube; do
  check_command "$cmd"
done
sleep 2

# Rutas y configuraciones
readonly WORKDIR="$HOME/despliegue-k8s"
readonly WEBSITE_REPO="https://github.com/HELTheSpectre/WebEstatica"
readonly MANIFESTS_REPO="https://github.com/HELTheSpectre/Manifiestos-k8s"
readonly MOUNT_PATH="/mnt/web"

echo "Creando carpeta de trabajo en $WORKDIR"
mkdir -p "$WORKDIR"
cd "$WORKDIR"

# Clonado de repositorios si no existen
clone_repo_if_missing() {
  local repo_url=$1
  local target_dir=$2

  if [ ! -d "$target_dir" ]; then
    echo "Clonando $repo_url en $target_dir"
    git clone "$repo_url" "$target_dir"
  else
    echo "Repositorio $target_dir ya existe, se omite clonación"
  fi
}
sleep 2

clone_repo_if_missing "$WEBSITE_REPO" "pagina-web"
clone_repo_if_missing "$MANIFESTS_REPO" "manifiestos-k8s"

# Iniciar Minikube con montaje automático
echo "Iniciando Minikube con VirtualBox y montando carpeta web..."
minikube start --driver=virtualbox \
  --mount=true \
  --mount-string="$WORKDIR/pagina-web:$MOUNT_PATH"

echo "Minikube iniciado correctamente."
sleep 2

# Aplicar manifiestos
echo "Aplicando manifiestos..."
cd "$WORKDIR/manifiestos-k8s"
kubectl apply -f pv.yaml
kubectl apply -f pvc.yaml
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
sleep 2

# Esperar que el pod esté en Running
echo "Esperando que el pod esté en estado Running..."
until kubectl get pods | grep sitio-web | grep -q "Running"; do
  echo "Aún esperando... revisando en 10s"
  sleep 10
done
echo "Pod en estado Running"

# Esperar endpoints activos
echo "Verificando endpoints del servicio..."
until [ "$(kubectl get endpoints sitio-web-service -o jsonpath='{.subsets[*].addresses[*].ip}')" != "" ]; do
  echo "Endpoints no disponibles aún... esperando 5s"
  sleep 5
done
echo "Servicio con endpoints activos"
sleep 1

# Mostrar estado
kubectl get pods
kubectl get svc

# Abrir servicio
echo "Abriendo el sitio web en el navegador..."
minikube service sitio-web-service

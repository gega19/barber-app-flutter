#!/bin/bash
# Ejecuta la app en modo dev apuntando al backend en esta máquina.
# Útil cuando pruebas en un dispositivo físico (teléfono) en la misma red WiFi.
#
# Requisitos: backend corriendo en esta PC (ej. npm run dev en barber-app-backend).
# Asegúrate de que el teléfono esté en la misma red WiFi.

set -e
cd "$(dirname "$0")/.."

# Obtener IP de la interfaz de red (Mac: en0 = Wi-Fi, en1 = Ethernet)
DEV_HOST=$(ipconfig getifaddr en0 2>/dev/null || ipconfig getifaddr en1 2>/dev/null || true)
if [ -z "$DEV_HOST" ]; then
  echo "No se pudo detectar la IP. Usa manualmente:"
  echo "  flutter run -t lib/main_dev.dart --dart-define=DEV_API_HOST=TU_IP"
  echo "Ejemplo: flutter run -t lib/main_dev.dart --dart-define=DEV_API_HOST=192.168.1.100"
  exit 1
fi

echo "Usando backend en: http://$DEV_HOST:3000"
echo "Conecta tu dispositivo por USB o selecciónalo si ya está conectado."
echo ""

flutter run -t lib/main_dev.dart --dart-define=DEV_API_HOST="$DEV_HOST"

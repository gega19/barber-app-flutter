#!/bin/bash
# Ejecuta la app en modo dev en el simulador de iOS.
# Usa 127.0.0.1 para conectar al backend en tu Mac (localhost).
#
# Requisitos: backend corriendo en esta Mac (ej. npm run dev en barber-app-backend).

set -e
cd "$(dirname "$0")/.."

echo "Backend esperado en: http://127.0.0.1:3000"
echo "Lanzando en simulador iOS..."
echo ""

flutter run -t lib/main_dev.dart --dart-define=DEV_API_HOST=127.0.0.1

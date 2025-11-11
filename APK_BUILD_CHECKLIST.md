# Checklist para Generar APK de Release

## ✅ Cambios Realizados

1. **Application ID actualizado**: `com.bartop.app` (antes: `com.example.flutterapp`)
2. **Namespace actualizado**: `com.bartop.app`
3. **LogInterceptor desactivado en release**: Solo se activa en modo debug
4. **URL de API**: Ya apunta a producción (Render)
5. **Nombre de la app**: "bartop" configurado en todos los lugares

## 📋 Verificaciones Adicionales

### Antes de Generar el APK

- [x] Application ID único configurado
- [x] URL de API apunta a producción
- [x] Logs de debug desactivados en release
- [x] Nombre de la app correcto
- [ ] Versión de la app actualizada (actual: 1.0.0+1)
- [ ] Icono de la app configurado

### Signing (Para Compartir con Compañero)

**Estado actual**: Usando debug signing (válido para pruebas)

**Para producción real**, necesitarías:

1. Crear un keystore
2. Configurar signing en `build.gradle.kts`
3. Guardar el keystore de forma segura

**Para compartir con tu compañero**: El APK con debug signing funcionará perfectamente.

## 🚀 Comandos para Generar el APK

```bash
# Limpiar build anterior
flutter clean

# Obtener dependencias
flutter pub get

# Generar APK de release
flutter build apk --release

# El APK estará en:
# build/app/outputs/flutter-apk/app-release.apk

# Para generar APK dividido por ABI (más pequeño):
flutter build apk --split-per-abi --release
```

## 📱 Instalación del APK

Tu compañero necesitará:

1. Habilitar "Instalar desde fuentes desconocidas" en Android
2. Transferir el archivo APK al dispositivo
3. Abrir el APK e instalar

## ⚠️ Notas Importantes

- El APK generado con debug signing **NO** puede publicarse en Google Play Store
- Para producción, necesitarás configurar un keystore de release
- El tamaño del APK puede ser grande (~50-100MB), considera usar `--split-per-abi` para reducir el tamaño

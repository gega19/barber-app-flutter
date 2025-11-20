# 🔐 Configuración de Firma para Producción

## ✅ Configuración Completada

La app está configurada para firmar con un keystore de producción.

### Archivos Creados

1. **`android/app-release-key.jks`** - Keystore de producción
2. **`android/key.properties`** - Credenciales de firma (NO subir a Git)

### Credenciales del Keystore

⚠️ **IMPORTANTE: Guarda estas credenciales en un lugar seguro**

```
Alias: bartop-release
Store Password: bartop2024!
Key Password: bartop2024!
Archivo: android/app-release-key.jks
```

## 📦 Construir APK Firmado

### Opción 1: APK Firmado

```bash
cd barber-app-flutter
flutter build apk --release
```

El APK firmado estará en:
```
build/app/outputs/flutter-apk/app-release.apk
```

### Opción 2: App Bundle (AAB) para Google Play

```bash
cd barber-app-flutter
flutter build appbundle --release
```

El AAB estará en:
```
build/app/outputs/bundle/release/app-release.aab
```

## 🔒 Seguridad

### ✅ Archivos Protegidos (en .gitignore)

- `android/key.properties` - NO se subirá a Git
- `android/app-release-key.jks` - NO se subirá a Git
- `android/*.jks` - NO se subirá a Git
- `android/*.keystore` - NO se subirá a Git

### ⚠️ IMPORTANTE

1. **NUNCA subas el keystore a Git**
2. **Guarda una copia del keystore en un lugar seguro** (cloud, USB, etc.)
3. **Si pierdes el keystore, NO podrás actualizar la app en Google Play**
4. **Comparte las credenciales solo con el equipo de desarrollo**

## 📝 Verificar Firma del APK

Para verificar que el APK está firmado correctamente:

```bash
# Ver información de la firma
jarsigner -verify -verbose -certs build/app/outputs/flutter-apk/app-release.apk

# Ver información del certificado
keytool -list -v -keystore android/app-release-key.jks -alias bartop-release
```

## 🚀 Subir a Google Play

1. Construye el AAB:
   ```bash
   flutter build appbundle --release
   ```

2. Ve a [Google Play Console](https://play.google.com/console)

3. Crea una nueva app o selecciona una existente

4. Sube el archivo `app-release.aab` desde:
   ```
   build/app/outputs/bundle/release/app-release.aab
   ```

5. Completa la información requerida (descripción, screenshots, etc.)

6. Publica la app

## 🔄 Actualizar la App

Para actualizar la app en Google Play:

1. Incrementa el `versionCode` en `pubspec.yaml`
2. Actualiza el `versionName` si es necesario
3. Construye el nuevo AAB:
   ```bash
   flutter build appbundle --release
   ```
4. Sube el nuevo AAB a Google Play Console

## 📱 Pruebas Locales

Para instalar el APK firmado en un dispositivo:

```bash
# Construir APK
flutter build apk --release

# Instalar en dispositivo conectado
adb install build/app/outputs/flutter-apk/app-release.apk
```

## 🆘 Problemas Comunes

### Error: "Keystore file not found"

- Verifica que `android/key.properties` existe
- Verifica que la ruta en `key.properties` es correcta

### Error: "Wrong password"

- Verifica las contraseñas en `key.properties`
- Asegúrate de que no hay espacios extra

### Error: "Alias not found"

- Verifica que el alias en `key.properties` es `bartop-release`
- Verifica que el keystore contiene ese alias

## 📞 Soporte

Si tienes problemas con la firma, verifica:
1. Que el keystore existe en `android/app-release-key.jks`
2. Que `key.properties` tiene las credenciales correctas
3. Que los archivos no están en .gitignore (deben estar ignorados)


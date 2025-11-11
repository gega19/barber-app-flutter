plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

android {
    namespace = "com.bartop.app"
    compileSdk = 36  // Android SDK 36 - Requerido por los plugins más recientes
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        // Habilitar core library desugaring para flutter_local_notifications
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // Application ID único para bartop
        applicationId = "com.bartop.app"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion  // Android 5.0 (Lollipop) - Compatible con la mayoría de dispositivos
        targetSdk = 34  // Android 14 - Versión objetivo actual recomendada
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Import the Firebase BoM (Bill of Materials)
    // This ensures all Firebase libraries use compatible versions
    implementation(platform("com.google.firebase:firebase-bom:33.7.0"))
    
    // Firebase Cloud Messaging
    implementation("com.google.firebase:firebase-messaging")
    
    // Firebase Analytics (opcional pero recomendado)
    implementation("com.google.firebase:firebase-analytics")
    
    // Core library desugaring (requerido para flutter_local_notifications)
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}

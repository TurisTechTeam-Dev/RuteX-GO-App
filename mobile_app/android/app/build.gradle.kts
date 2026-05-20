import java.util.Properties

plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val dotenv = Properties()
val dotenvFile = rootProject.file("../.env")
if (dotenvFile.exists()) {
    dotenvFile.inputStream().use { dotenv.load(it) }
}
val mapsApiKey: String = dotenv.getProperty("Maps_API_KEY")
    ?: System.getenv("Maps_API_KEY")
    ?: ""
val googleDirectionsApiKey: String = dotenv.getProperty("Google_Directions_API_KEY")
    ?: dotenv.getProperty("GOOGLE_DIRECTIONS_API_KEY")
    ?: System.getenv("Google_Directions_API_KEY")
    ?: System.getenv("GOOGLE_DIRECTIONS_API_KEY")
    ?: mapsApiKey

android {
    namespace = "com.rutexgo.mobile_app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    // CONFIGURACIÓN DE FIRMA PARA TUS PROFESORES
    signingConfigs {
        create("release") {
            // Asegúrate de que el archivo key.jks esté en la carpeta android/app/
            storeFile = file("key.jks")
            storePassword = "123456"
            keyAlias = "alias_profes"
            keyPassword = "123456"
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_21
        targetCompatibility = JavaVersion.VERSION_21
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_21.toString()
    }

    buildFeatures {
        buildConfig = true
    }

    defaultConfig {
        applicationId = "com.rutexgo.mobile_app"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        resValue("string", "Maps_API_KEY", mapsApiKey)
        buildConfigField("String", "GOOGLE_DIRECTIONS_API_KEY", "\"$googleDirectionsApiKey\"")
    }

    buildTypes {
        getByName("debug") {
            // usa el debug keystore por defecto (~/.android/debug.keystore)
        }
        release {
            // USAMOS LA CONFIGURACIÓN DE RELEASE EN LUGAR DE DEBUG
            signingConfig = signingConfigs.getByName("release")

            // Opcional: optimizaciones de código
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }
}

flutter {
    source = "../.."
}
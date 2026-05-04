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
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.rutexgo.mobile_app"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        resValue("string", "Maps_API_KEY", mapsApiKey)
        buildConfigField("String", "GOOGLE_DIRECTIONS_API_KEY", "\"$googleDirectionsApiKey\"")
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

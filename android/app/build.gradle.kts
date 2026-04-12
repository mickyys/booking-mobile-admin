plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "cl.reservaloya.reservaloya_admin"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "cl.reservaloya.reservaloya_admin"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = 21 // auth0_flutter requires minSdk 21
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
<<<<<<< HEAD
        manifestPlaceholders.putAll(
            mapOf(
                "auth0Domain" to "dev-8obo6dl4.us.auth0.com",
                "auth0Scheme" to "https"
            )
        )
=======

        manifestPlaceholders["auth0Domain"] = "dev-8obo6dl4.us.auth0.com"
        manifestPlaceholders["auth0Scheme"] = "demo"
>>>>>>> 03ebf6e3dc618e58397ac029557d805057764fa8
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

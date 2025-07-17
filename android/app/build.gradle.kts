import java.util.Properties

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(keystorePropertiesFile.inputStream())
}

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.chalan_book_app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.chalan_book_app"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

   // signingConfigs {
     //   create("release") {
       //     val storeFilePath = keystoreProperties["storeFile"]?.toString()
         //   println("🟢 KEYSTORE PATH: $storeFilePath")
//
  //          if (storeFilePath.isNullOrBlank()) {
    //            throw GradleException("❌ storeFile is missing in key.properties")
      //      }
//
  //          keyAlias = keystoreProperties["keyAlias"]?.toString() ?: ""
    //        keyPassword = keystoreProperties["keyPassword"]?.toString() ?: ""
      //      storeFile = file(storeFilePath)
        //    storePassword = keystoreProperties["storePassword"]?.toString() ?: ""
    //    }
   // }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
            isMinifyEnabled = false
            isShrinkResources = false
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
        }
    }
}

flutter {
    source = "../.."
}

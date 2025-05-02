#!/bin/bash

# Script to build TimeCapsule APK with compatibility fixes
echo "=========================================="
echo "TimeCapsule APK Builder"
echo "=========================================="

# Step 1: Update Android build.gradle with compatibility settings
echo "1. Updating Android build.gradle for Java compatibility..."

# Create backup of original build.gradle
cp android/app/build.gradle android/app/build.gradle.backup

# Update build.gradle with Java 8 compatibility
cat > android/app/build.gradle << 'EOL'
def localProperties = new Properties()
def localPropertiesFile = rootProject.file('local.properties')
if (localPropertiesFile.exists()) {
    localPropertiesFile.withReader('UTF-8') { reader ->
        localProperties.load(reader)
    }
}

def flutterRoot = localProperties.getProperty('flutter.sdk')
if (flutterRoot == null) {
    throw new GradleException("Flutter SDK not found. Define location with flutter.sdk in the local.properties file.")
}

def flutterVersionCode = localProperties.getProperty('flutter.versionCode')
if (flutterVersionCode == null) {
    flutterVersionCode = '1'
}

def flutterVersionName = localProperties.getProperty('flutter.versionName')
if (flutterVersionName == null) {
    flutterVersionName = '1.0'
}

apply plugin: 'com.android.application'
apply plugin: 'kotlin-android'
apply from: "$flutterRoot/packages/flutter_tools/gradle/flutter.gradle"

android {
    compileSdkVersion 33

    compileOptions {
        sourceCompatibility JavaVersion.VERSION_1_8
        targetCompatibility JavaVersion.VERSION_1_8
    }

    kotlinOptions {
        jvmTarget = '1.8'
    }

    sourceSets {
        main.java.srcDirs += 'src/main/kotlin'
    }

    defaultConfig {
        applicationId "com.example.time_capsule"
        minSdkVersion 21
        targetSdkVersion 33
        versionCode flutterVersionCode.toInteger()
        versionName flutterVersionName
    }

    buildTypes {
        release {
            signingConfig signingConfigs.debug
        }
    }
}

flutter {
    source '../..'
}

dependencies {
    implementation "org.jetbrains.kotlin:kotlin-stdlib-jdk8:$kotlin_version"
}
EOL

echo "Build.gradle updated successfully."

# Step 2: Update gradle.properties
echo "2. Updating gradle.properties with JVM settings..."

# Create backup of original gradle.properties
cp android/gradle.properties android/gradle.properties.backup

# Update gradle.properties
cat > android/gradle.properties << 'EOL'
org.gradle.jvmargs=-Xmx1536M -Dkotlin.daemon.jvm.options\="-Xmx1536M" --add-exports=java.base/sun.nio.ch=ALL-UNNAMED --add-opens=java.base/java.lang=ALL-UNNAMED
android.useAndroidX=true
android.enableJetifier=true
android.nonTransitiveRClass=true
EOL

echo "Gradle properties updated successfully."

# Step 3: Clean the project
echo "3. Cleaning Flutter project..."
flutter clean

# Step 4: Get dependencies
echo "4. Getting Flutter dependencies..."
flutter pub get

# Step 5: Build the APK
echo "5. Building debug APK with optimized settings..."
flutter build apk --debug --no-tree-shake-icons

if [ $? -eq 0 ]; then
    echo "=========================================="
    echo "✅ APK build completed successfully!"
    echo "APK location: build/app/outputs/flutter-apk/app-debug.apk"
    echo "=========================================="
else
    echo "=========================================="
    echo "❌ APK build failed."
    echo "Please check the error messages above."
    echo "=========================================="
fi 
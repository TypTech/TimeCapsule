@echo off
SETLOCAL

REM Script to build TimeCapsule APK with compatibility fixes
echo ===========================================
echo TimeCapsule APK Builder (Windows)
echo ===========================================

REM Check if we have build.gradle or build.gradle.kts
IF EXIST android\app\build.gradle.kts (
    echo Using Kotlin DSL build script (build.gradle.kts)
    
    REM Create backup of original build.gradle.kts
    copy android\app\build.gradle.kts android\app\build.gradle.kts.backup > nul
    
    REM Update build.gradle.kts with Java 8 compatibility
    echo import org.jetbrains.kotlin.gradle.tasks.KotlinCompile > android\app\build.gradle.kts
    echo. >> android\app\build.gradle.kts
    echo plugins { >> android\app\build.gradle.kts
    echo     id("com.android.application") >> android\app\build.gradle.kts
    echo     kotlin("android") >> android\app\build.gradle.kts
    echo     id("dev.flutter.flutter-gradle-plugin") >> android\app\build.gradle.kts
    echo } >> android\app\build.gradle.kts
    echo. >> android\app\build.gradle.kts
    echo android { >> android\app\build.gradle.kts
    echo     namespace = "com.example.time_capsule" >> android\app\build.gradle.kts
    echo     compileSdk = 33 >> android\app\build.gradle.kts
    echo. >> android\app\build.gradle.kts
    echo     defaultConfig { >> android\app\build.gradle.kts
    echo         applicationId = "com.example.time_capsule" >> android\app\build.gradle.kts
    echo         minSdk = 21 >> android\app\build.gradle.kts
    echo         targetSdk = 33 >> android\app\build.gradle.kts
    echo         versionCode = 1 >> android\app\build.gradle.kts
    echo         versionName = "1.0" >> android\app\build.gradle.kts
    echo     } >> android\app\build.gradle.kts
    echo. >> android\app\build.gradle.kts
    echo     compileOptions { >> android\app\build.gradle.kts
    echo         sourceCompatibility = JavaVersion.VERSION_1_8 >> android\app\build.gradle.kts
    echo         targetCompatibility = JavaVersion.VERSION_1_8 >> android\app\build.gradle.kts
    echo     } >> android\app\build.gradle.kts
    echo. >> android\app\build.gradle.kts
    echo     kotlinOptions { >> android\app\build.gradle.kts
    echo         jvmTarget = "1.8" >> android\app\build.gradle.kts
    echo     } >> android\app\build.gradle.kts
    echo. >> android\app\build.gradle.kts
    echo     buildTypes { >> android\app\build.gradle.kts
    echo         release { >> android\app\build.gradle.kts
    echo             // Apply ProGuard only for release builds >> android\app\build.gradle.kts
    echo             signingConfig = signingConfigs.getByName("debug") >> android\app\build.gradle.kts
    echo         } >> android\app\build.gradle.kts
    echo     } >> android\app\build.gradle.kts
    echo } >> android\app\build.gradle.kts
    echo. >> android\app\build.gradle.kts
    echo flutter { >> android\app\build.gradle.kts
    echo     source = ".." >> android\app\build.gradle.kts
    echo } >> android\app\build.gradle.kts

) ELSE (
    echo Using Groovy build script (build.gradle)
    
    REM Create backup of original build.gradle
    copy android\app\build.gradle android\app\build.gradle.backup > nul
    
    REM Update build.gradle with Java 8 compatibility
    echo def localProperties = new Properties() > android\app\build.gradle
    echo def localPropertiesFile = rootProject.file('local.properties') >> android\app\build.gradle
    echo if (localPropertiesFile.exists()) { >> android\app\build.gradle
    echo     localPropertiesFile.withReader('UTF-8') { reader -^> >> android\app\build.gradle
    echo         localProperties.load(reader) >> android\app\build.gradle
    echo     } >> android\app\build.gradle
    echo } >> android\app\build.gradle
    echo. >> android\app\build.gradle
    echo def flutterRoot = localProperties.getProperty('flutter.sdk') >> android\app\build.gradle
    echo if (flutterRoot == null) { >> android\app\build.gradle
    echo     throw new GradleException("Flutter SDK not found. Define location with flutter.sdk in the local.properties file.") >> android\app\build.gradle
    echo } >> android\app\build.gradle
    echo. >> android\app\build.gradle
    echo def flutterVersionCode = localProperties.getProperty('flutter.versionCode') >> android\app\build.gradle
    echo if (flutterVersionCode == null) { >> android\app\build.gradle
    echo     flutterVersionCode = '1' >> android\app\build.gradle
    echo } >> android\app\build.gradle
    echo. >> android\app\build.gradle
    echo def flutterVersionName = localProperties.getProperty('flutter.versionName') >> android\app\build.gradle
    echo if (flutterVersionName == null) { >> android\app\build.gradle
    echo     flutterVersionName = '1.0' >> android\app\build.gradle
    echo } >> android\app\build.gradle
    echo. >> android\app\build.gradle
    echo apply plugin: 'com.android.application' >> android\app\build.gradle
    echo apply plugin: 'kotlin-android' >> android\app\build.gradle
    echo apply from: "$flutterRoot/packages/flutter_tools/gradle/flutter.gradle" >> android\app\build.gradle
    echo. >> android\app\build.gradle
    echo android { >> android\app\build.gradle
    echo     compileSdkVersion 33 >> android\app\build.gradle
    echo. >> android\app\build.gradle
    echo     compileOptions { >> android\app\build.gradle
    echo         sourceCompatibility JavaVersion.VERSION_1_8 >> android\app\build.gradle
    echo         targetCompatibility JavaVersion.VERSION_1_8 >> android\app\build.gradle
    echo     } >> android\app\build.gradle
    echo. >> android\app\build.gradle
    echo     kotlinOptions { >> android\app\build.gradle
    echo         jvmTarget = '1.8' >> android\app\build.gradle
    echo     } >> android\app\build.gradle
    echo. >> android\app\build.gradle
    echo     sourceSets { >> android\app\build.gradle
    echo         main.java.srcDirs += 'src/main/kotlin' >> android\app\build.gradle
    echo     } >> android\app\build.gradle
    echo. >> android\app\build.gradle
    echo     defaultConfig { >> android\app\build.gradle
    echo         applicationId "com.example.time_capsule" >> android\app\build.gradle
    echo         minSdkVersion 21 >> android\app\build.gradle
    echo         targetSdkVersion 33 >> android\app\build.gradle
    echo         versionCode flutterVersionCode.toInteger() >> android\app\build.gradle
    echo         versionName flutterVersionName >> android\app\build.gradle
    echo     } >> android\app\build.gradle
    echo. >> android\app\build.gradle
    echo     buildTypes { >> android\app\build.gradle
    echo         release { >> android\app\build.gradle
    echo             signingConfig signingConfigs.debug >> android\app\build.gradle
    echo         } >> android\app\build.gradle
    echo     } >> android\app\build.gradle
    echo } >> android\app\build.gradle
    echo. >> android\app\build.gradle
    echo flutter { >> android\app\build.gradle
    echo     source '../..' >> android\app\build.gradle
    echo } >> android\app\build.gradle
    echo. >> android\app\build.gradle
    echo dependencies { >> android\app\build.gradle
    echo     implementation "org.jetbrains.kotlin:kotlin-stdlib-jdk8:$kotlin_version" >> android\app\build.gradle
    echo } >> android\app\build.gradle
)

echo Build.gradle updated successfully.

REM Step 2: Update gradle.properties
echo 2. Updating gradle.properties with JVM settings...

REM Create backup of original gradle.properties
copy android\gradle.properties android\gradle.properties.backup > nul

REM Update gradle.properties - Make sure there's no space after true/false values
echo org.gradle.jvmargs=-Xmx1536M -Dkotlin.daemon.jvm.options\="-Xmx1536M" --add-exports=java.base/sun.nio.ch=ALL-UNNAMED --add-opens=java.base/java.lang=ALL-UNNAMED > android\gradle.properties
echo android.useAndroidX=true>> android\gradle.properties
echo android.enableJetifier=true>> android\gradle.properties
echo android.nonTransitiveRClass=true>> android\gradle.properties

echo Gradle properties updated successfully.

REM Step 3: Clean the project
echo 3. Cleaning Flutter project...
call flutter clean

REM Step 4: Get dependencies
echo 4. Getting Flutter dependencies...
call flutter pub get

REM Step 5: Build the APK
echo 5. Building debug APK with optimized settings...
call flutter build apk --debug --no-tree-shake-icons

if %ERRORLEVEL% EQU 0 (
    echo ===========================================
    echo ✅ APK build completed successfully!
    echo APK location: build\app\outputs\flutter-apk\app-debug.apk
    echo ===========================================
) else (
    echo ===========================================
    echo ❌ APK build failed.
    echo Please check the error messages above.
    echo ===========================================
)

ENDLOCAL 
# TimeCapsule Build Instructions

## Resolving APK Build Issues

This document provides step-by-step solutions for the Java/Kotlin compatibility issues encountered when building the APK for TimeCapsule.

### Issue: JDK/JVM Compatibility Problems

The main issues encountered are:
1. JVM version compatibility between various plugins
2. Older Gradle plugin scripts that don't work with modern JVM settings
3. Inconsistencies between build.gradle and build.gradle.kts configurations

### Manual Fix Steps (Most Reliable)

Follow these steps exactly to build a working APK:

1. **Fix APK build issues in Android configuration files**:

   **If using build.gradle (not .kts)**:
   Edit `android/app/build.gradle` and ensure these settings:

   ```groovy
   android {
       compileSdkVersion 33
       
       compileOptions {
           sourceCompatibility JavaVersion.VERSION_1_8
           targetCompatibility JavaVersion.VERSION_1_8
       }
       
       kotlinOptions {
           jvmTarget = '1.8'
       }

       // Make sure defaultConfig has these minimum settings:
       defaultConfig {
           minSdkVersion 21
           targetSdkVersion 33
       }
   }
   ```

   **If using build.gradle.kts**:
   Edit `android/app/build.gradle.kts` and make these changes:

   ```kotlin
   android {
       compileSdk = 33
       
       compileOptions {
           sourceCompatibility = JavaVersion.VERSION_1_8
           targetCompatibility = JavaVersion.VERSION_1_8
       }
       
       kotlinOptions {
           jvmTarget = "1.8"
       }

       defaultConfig {
           minSdk = 21
           targetSdk = 33
       }
   }
   ```

2. **Fix gradle.properties settings**:

   Edit `android/gradle.properties` and make sure it contains these settings (no spaces after true/false values):

   ```
   org.gradle.jvmargs=-Xmx1536M -Dkotlin.daemon.jvm.options\="-Xmx1536M"
   android.useAndroidX=true
   android.enableJetifier=true
   android.nonTransitiveRClass=true
   ```

3. **Clean build and get dependencies**:

   ```
   flutter clean
   flutter pub get
   ```

4. **Build debug APK with special flags**:

   ```
   flutter build apk --debug --no-tree-shake-icons
   ```

### Common Problems and Solutions

1. **Problem**: Error about Android x86 targets being removed
   **Solution**: This is a warning but not a breaking error

2. **Problem**: Cannot parse android.useAndroidX='true ' as boolean
   **Solution**: Remove any spaces after 'true' in gradle.properties

3. **Problem**: Conflicts between plugins requiring different JVM versions
   **Solution**: Always use Java 8 compatibility settings as shown above

4. **Problem**: Error about Flutter's main Gradle plugin being applied imperatively
   **Solution**: Make sure you're using the latest Flutter SDK and that the build.gradle/.kts files are correctly configured for your Flutter version (run 'flutter doctor' to check your setup)

5. **Problem**: Issues with build.gradle.kts vs build.gradle files
   **Solution**: Make sure you're editing the right file - some projects use Kotlin DSL (.kts) while others use Groovy (no extension)

### Additional Options

If the above steps don't work, you can try these alternatives:

1. **Temporarily disable problematic plugins** in pubspec.yaml:

   ```yaml
   dependencies:
     # Comment out these problematic plugins
     # video_player: ^x.x.x
   ```

2. **Use a specific Flutter version**:

   ```
   flutter channel stable
   flutter upgrade
   flutter pub get
   flutter build apk
   ```

3. **Try a release build with proguard disabled**:

   ```
   flutter build apk --release --no-shrink
   ```

## After Building Successfully

The APK will be available at:
```
build/app/outputs/flutter-apk/app-debug.apk
```

You can install it directly with:
```
flutter install
```

## Identifying Specific Plugin Issues

To identify which plugins are causing conflicts:

1. Run `flutter build apk -v` to see verbose output
2. Look for error messages related to specific plugins
3. Check the build logs for JVM/Java version conflicts
4. Isolate problematic plugins by temporarily removing them

## Testing the APK

After building successfully:

1. Install on device: `flutter install`
2. Or find the APK at: `build/app/outputs/flutter-apk/app-debug.apk`

## Getting Help

If you continue to encounter issues:

1. Check the Flutter issue tracker for known problems with specific plugins
2. Update plugins to their latest compatible versions
3. Consider using alternative plugins with similar functionality 
# TimeCapsule

TimeCapsule is a Flutter application that helps you create, organize, and preserve your memories in beautiful photo collections.

## Features

- **Photo Collections**: Add and organize photos into themed collections
- **Multiple Themes**: Choose from various themes to customize your capsules
- **Local Storage**: All your memories are stored safely on your device
- **Preview Gallery**: View your photos in an elegant carousel
- **User Preferences**: Customize your experience with user settings
- **Dark Mode Support**: Enjoy TimeCapsule in light or dark mode

## Getting Started

### Prerequisites

- Flutter SDK (latest stable version recommended)
- Android Studio or Visual Studio Code with Flutter extensions
- Android emulator or physical device for testing

### Installation

1. Clone this repository:
```
git clone https://github.com/yourusername/timecapsule.git
```

2. Navigate to the project directory:
```
cd timecapsule
```

3. Install dependencies:
```
flutter pub get
```

4. Run the app:
```
flutter run
```

## Building an APK

To build an APK for Android devices, please refer to the detailed instructions in the `BUILD_INSTRUCTIONS.md` file. This document provides solutions for common build issues, particularly related to Java/Kotlin compatibility.

## App Structure

- **lib/screens/**: UI screens of the application
- **lib/services/**: Business logic and data management services
- **lib/widgets/**: Reusable UI components
- **lib/main.dart**: Entry point of the application

## Features Implementation

### Photo Selection
The app uses the `image_picker` package for selecting photos from the device gallery or taking new photos with the camera. Selected photos are processed through the `MediaService` class.

### Theme Management
The app supports multiple themes managed by the `ThemeService`. Users can switch between light and dark modes, as well as different theme styles.

### Local Storage
All data is stored locally on the device using a combination of Hive database (for capsule metadata) and file system storage (for photos).

## Known Issues and Limitations

- APK generation may encounter Java/Kotlin compatibility issues due to plugin interdependencies
- Video processing features are currently unavailable due to dependency conflicts

## Future Improvements

- Add support for video content
- Implement sharing functionality
- Add cloud backup options
- Enhance photo editing capabilities

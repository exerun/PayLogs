# PayLogs - Personal Finance Tracker

A modern Flutter app for tracking personal finances with beautiful UI and responsive design.

## Features

- 📊 Transaction management with categorized expenses, income, and transfers
- 🎨 Modern tab-based UI with responsive design
- 🌙 Dark/Light theme support
- 📱 Cross-platform support (Android, iOS, Web, Desktop)
- 💾 Local data storage with Hive
- 📈 Budget tracking and analysis

## Prerequisites

Before running this project, ensure you have:

- **Flutter SDK** (3.8.1 or higher)
- **Dart SDK** (3.8.1 or higher)
- **Java Development Kit (JDK)** - Version 17 recommended
- **Android Studio** (for Android development)
- **Xcode** (for iOS development, macOS only)

## Setup Instructions

### 1. Clone the Repository

```bash
git clone <your-repository-url>
cd p
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Platform-Specific Setup

#### Android
- Ensure you have Android SDK installed
- Set up Android emulator or connect a physical device
- The project uses Gradle 8.12 and targets Android API 21+

#### iOS (macOS only)
- Install Xcode from the App Store
- Open iOS Simulator or connect an iPhone
- Run `cd ios && pod install` if you encounter CocoaPods issues

#### Desktop (Windows/Linux/macOS)
- Enable desktop support: `flutter config --enable-windows-desktop` (Windows)
- Enable desktop support: `flutter config --enable-linux-desktop` (Linux)
- Enable desktop support: `flutter config --enable-macos-desktop` (macOS)

### 4. Run the App

```bash
# For debug mode
flutter run

# For specific platform
flutter run -d android
flutter run -d ios
flutter run -d windows
flutter run -d linux
flutter run -d macos
```

## Build Instructions

### Android APK
```bash
flutter build apk --release
```

### Android App Bundle
```bash
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

### Desktop
```bash
flutter build windows --release
flutter build linux --release
flutter build macos --release
```

## Project Structure

```
lib/
├── assets/           # Images, fonts, and other assets
├── data/            # Data models and providers
├── models/          # Transaction and other data models
├── pages/           # Main app screens
├── providers/       # State management
├── widgets/         # Reusable UI components
└── main.dart        # App entry point
```

## Dependencies

- **provider**: State management
- **hive**: Local database
- **fl_chart**: Charts and graphs
- **google_ml_kit**: Text recognition
- **shared_preferences**: Settings storage
- **path_provider**: File system access

## Troubleshooting

### JVM Compatibility Issues
If you encounter JVM target compatibility errors:

1. Ensure you have JDK 17 installed
2. Set JAVA_HOME environment variable
3. Run `flutter clean` and `flutter pub get`
4. If issues persist, try using JDK 11 instead

### Platform-Specific Issues

#### Windows
- Ensure you have Visual Studio Build Tools installed
- Set up Android SDK properly
- Use Windows Terminal or PowerShell for better compatibility

#### macOS
- Install Xcode Command Line Tools: `xcode-select --install`
- Ensure CocoaPods is installed: `sudo gem install cocoapods`

#### Linux
- Install required packages: `sudo apt-get install libgtk-3-dev`
- Ensure you have proper graphics drivers installed

### Common Flutter Issues

```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter run

# Update Flutter
flutter upgrade

# Doctor command to check setup
flutter doctor
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test on multiple platforms
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For issues and questions:
- Check the troubleshooting section above
- Search existing GitHub issues
- Create a new issue with detailed information about your problem

# DressApp

A Flutter application for managing your digital wardrobe.

## Features

- 📱 **Digital Closet Management**: Add and organize your clothing items
- 📸 **Photo Capture**: Take photos or choose from gallery
- 🎨 **Simple Interface**: Clean, modern UI with your preferred color scheme
- 💾 **Local Storage**: All data stored locally on your device

## Getting Started

### Prerequisites

- Flutter SDK (latest stable version)
- Android Studio / VS Code
- Android device or emulator

### Installation

1. Clone the repository:
```bash
git clone <your-repo-url>
cd dressapp
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

## Build Commands

- **Debug build**: `flutter build apk --debug`
- **Release build**: `flutter build apk --release`
- **Profile build**: `flutter build apk --profile`

## Project Structure

```
lib/
├── core/           # Core utilities and services
├── features/       # Feature modules
│   ├── auth/       # Authentication
│   ├── home/       # Main app functionality
│   ├── onboarding/ # Onboarding flow
│   ├── preferences/# User preferences
│   ├── questions/  # Setup questions
│   ├── setup/      # Initial setup
│   └── splash/     # Splash screen
└── shared/         # Shared components
```

## Color Scheme

- **Primary Text**: #461700 (Dark Brown)
- **Background**: #FEFAD4 (Cream)
- **Page Background**: Gradient from white to #FEFAD4

## Development

The app is built with Flutter and uses:
- **State Management**: Riverpod
- **Database**: SQLite (via sqflite)
- **Authentication**: Google Sign-In, Apple Sign-In, Email
- **Image Picker**: For capturing and selecting photos

## License

This project is licensed under the MIT License.

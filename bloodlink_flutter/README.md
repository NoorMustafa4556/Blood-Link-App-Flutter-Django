# BloodLink Mobile App (Flutter) 📱

A professional, cross-platform mobile application designed for efficient blood donation management.

## ✨ Key Features
- **Real-time Request Tracking:** Never miss a life-saving opportunity.
- **Accurate Countdown:** Intelligent timer synced with the server to show exact expiration.
- **Secure Authentication:** JWT-based login and registration.
- **Profile Management:** Update availability, location, and contact info easily.
- **Push-like Experience:** Polling mechanism ensures you see new requests within seconds.

## 🛠️ Setup Instructions

### 1. Prerequisites
*   Flutter SDK (Latest stable version)
*   Android Studio / VS Code
*   A running instance of the BloodLink Django Backend.

### 2. Configuration
Open `lib/utils/Config.dart` and update the `baseUrl` with your computer's local IP address:
```dart
static const String baseUrl = kIsWeb 
    ? 'http://localhost:8000' 
    : 'http://192.168.100.231:8000'; // Change this IP
```

### 3. Run the App
```bash
flutter pub get
flutter run
```

## 🏗️ Architecture
- **State Management:** Provider
- **Networking:** Dio (with Interceptors for Auth)
- **Local Storage:** Flutter Secure Storage
- **UI Design:** Material 3 with Custom Styling

---
*Part of the BloodLink Unified Platform*

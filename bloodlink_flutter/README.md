# BloodLink Mobile App (Flutter) 📱

A professional, cross-platform mobile application designed for efficient blood donation tracking, donor discovery, and real-time request notifications.

---

## ✨ Features

- **Dynamic Dropdowns (API Integration):** Fetches cities and blood groups from the Django REST backend, falling back to local configurations offline.
- **Provider-Based Architecture:** Uses ChangeNotifier Provider to manage authentication states, user role states, and request streams.
- **Flexible Offline Defaults:** Works offline during presentations using static structures from `Constants.dart`.
- **Countdown Duration Timers:** Displays reactive countdown indicators for urgent blood requests based on duration parameters.
- **Dual Dashboard Modes:** Switch between Donor mode (receive requests, edit availability) and Recipient mode (create request, search donors) dynamically.

---

## 🛠️ Configuration & Setup

### 1. Prerequisites
- Flutter SDK (stable version)
- Android Studio / VS Code with Dart plugins
- A physical device or emulator connected to the local server network.

### 2. Configure Local Host Server IP
Before running, configure `lib/utils/Config.dart` with your development computer's local IP address:
```dart
class AppConfig {
  static const String baseUrl = 'http://192.168.100.x:8000'; // Replace with your IPv4 address
}
```

### 3. Run Commands
Retrieve packages:
```bash
flutter pub get
```

Run application:
```bash
flutter run
```

---

## 🏗️ Folder Structure

- 📂 `lib/models/` - Declares Dart structures matching backend serialization.
- 📂 `lib/providers/` - Manages app state (`AuthProvider` and `BloodProvider`).
- 📂 `lib/screens/` - UI pages (Auth, Home dashboard, Donor searches, Profiles).
- 📂 `lib/services/` - Base client (`ApiService`) for sending structured HTTP requests.
- 📂 `lib/utils/` - Static configurations, theme configurations, and constants.

---
*Part of the BloodLink Unified Platform*

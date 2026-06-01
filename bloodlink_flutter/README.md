# BloodLink Mobile App (Flutter) 📱

A professional, cross-platform mobile application built with Flutter for efficient blood donation management — connecting donors with recipients in real-time.

---

## 📋 Table of Contents

- [Overview](#overview)
- [Features](#features)
- [App Workflow](#app-workflow)
- [Architecture](#architecture)
- [Folder Structure](#folder-structure)
- [Configuration & Setup](#configuration--setup)
- [Screenshots](#screenshots)

---

## 🔍 Overview

BloodLink Flutter App is the mobile client of the BloodLink platform. It communicates with the Django REST backend to enable user authentication, real-time blood request management, donor discovery, and full profile management — all through a sleek, modern UI.

The app supports two user modes:
- **🩸 Donor Mode** — Receive blood requests, manage availability, accept or reject requests.
- **🙋 Recipient Mode** — Send blood requests to available donors, track request statuses, view history.

---

## ✨ Features

### 🔐 Authentication
- JWT-based secure login and registration.
- Auto-login on restart using `flutter_secure_storage`.
- Role selection during login (Donor / Recipient).
- Unique username and email validation at registration.

### 🏠 Home Dashboard
- **Donor Dashboard:** Lists incoming pending blood requests with real-time countdown timers showing how many minutes remain before each request expires.
- **Recipient Dashboard:** Shows status of all sent requests with Accept/Reject badges.
- **5-Second Polling:** Background timer polls the server every 5 seconds to keep the home screen in sync without a manual refresh.

### 🩸 Blood Request System
- Recipients can send a full blood request form: Patient Name, Blood Group, City, Hospital Name, Message, and Duration.
- Donors can Accept or Reject any incoming request with an optional message.
- Contact information (phone/email) is revealed only after a request is accepted.
- Requests automatically expire and are marked `Cancelled` after their defined duration.

### 🔍 Donor Search
- Search available donors by **Blood Group** and **City**.
- Live filtering with city autocomplete fetched from the backend API.
- Tap a donor card to view their full profile before sending a request.

### 📊 History Screen
- View **Sent Requests** and **Received Requests** in separate tabs.
- Filter by **Pending**, **Accepted**, and **Rejected** within each tab.
- Tap any request to view its full detail page.

### 👤 Profile Management
- View full profile: Username, Email, Phone, City, Blood Group, Gender, Donor Status.
- Edit profile: Update name, phone, city, availability, and profile picture.
- Phone number is visible only to the profile owner — hidden from others.

### 🎨 Theme & UI
- Light and Dark Mode support via `ThemeProvider`.
- Custom `CustomDrawer` widget for sidebar navigation.
- Dynamic dropdowns: Cities and Blood Groups fetched from API, falling back to `Constants.dart` if offline.

---

## 🔄 App Workflow

```
App Launch
    │
    ▼
SplashScreen (checks stored token)
    │
    ├── Token Found ──► Auto Login ──► Home Dashboard
    │
    └── No Token ──► Landing Screen
                          │
                    ┌─────┴─────┐
                    ▼           ▼
               Login         Sign Up
                    │           │
                    └─────┬─────┘
                          ▼
                   Role Selection
                  (Donor/Recipient)
                          │
                          ▼
                   Home Dashboard
                  ┌──────┴───────┐
                  ▼              ▼
           Donor Mode      Recipient Mode
          (Requests In)   (Requests Sent)
                  │              │
          Accept/Reject      Send Request
                  │              │
           History Tab      History Tab
                  │              │
              View Detail    View Detail
```

---

## 🏗️ Architecture

| Layer | Technology | Role |
|---|---|---|
| **State Management** | `Provider` (ChangeNotifier) | Manages auth state, role, and request data |
| **Networking** | `Dio` with Interceptors | All HTTP calls with JWT token injection |
| **Local Storage** | `flutter_secure_storage` | Stores JWT tokens and user role |
| **UI** | Material 3 + Custom Styling | Themed components and screens |

### Key Providers
- **`AuthProvider`** — Handles login, logout, registration, auto-login, profile updates and password changes.
- **`BloodProvider`** — Manages donor list, request lists, real-time polling, city/blood group dynamic lists.
- **`ThemeProvider`** — Toggles light/dark mode.

---

## 📂 Folder Structure

```
bloodlink_flutter/
├── lib/
│   ├── main.dart                        # App entry point, provider setup
│   ├── models/
│   │   ├── User.dart                    # User + UserProfile model
│   │   └── BloodRequest.dart            # Blood request model
│   ├── providers/
│   │   ├── AuthProvider.dart            # Auth state management
│   │   ├── BloodProvider.dart           # Requests, donors, polling
│   │   └── ThemeProvider.dart           # Theme toggle
│   ├── screens/
│   │   ├── splash/
│   │   │   └── SplashScreen.dart        # Token-check splash
│   │   ├── auth/
│   │   │   ├── LoginScreen.dart         # JWT login
│   │   │   └── SignUpScreen.dart        # Registration form
│   │   ├── home/
│   │   │   ├── HomeScreen.dart          # Donor/Recipient dashboard
│   │   │   ├── RequestBloodForm.dart    # Send request form
│   │   │   └── RequestDetailScreen.dart # Full request detail + accept/reject
│   │   ├── search/
│   │   │   ├── SearchDonorScreen.dart   # Donor search with filters
│   │   │   └── DonorProfileScreen.dart  # Individual donor profile
│   │   ├── history/
│   │   │   └── HistoryScreen.dart       # Sent/Received history tabs
│   │   └── profile/
│   │       ├── ProfileScreen.dart       # My profile view
│   │       └── EditProfileScreen.dart   # Edit profile form
│   ├── services/
│   │   └── ApiService.dart              # All REST API calls via Dio
│   ├── utils/
│   │   ├── Config.dart                  # Base URL configuration
│   │   └── Constants.dart               # Offline fallback cities & blood groups (auto-synced)
│   └── widgets/
│       └── CustomDrawer.dart            # Sidebar navigation drawer
└── assets/
    └── images/                          # App screenshots (1.png – 38.png)
```

---

## ⚙️ Configuration & Setup

### 1. Prerequisites
- Flutter SDK (stable channel, 3.x+)
- Android Studio or VS Code with Flutter & Dart plugins
- A running BloodLink Django backend (see `/Blood Link Django/README.md`)

### 2. Configure Backend URL

Open `lib/utils/Config.dart` and set your backend server IP:

```dart
class AppConfig {
  // For physical device on local Wi-Fi/Hotspot:
  static const String baseUrl = 'http://192.168.x.x:8000';

  // For Android emulator (localhost):
  // static const String baseUrl = 'http://10.0.2.2:8000';
}
```

> **Tip:** Run `ipconfig` on Windows to find your IPv4 address. The mobile and laptop must be on the same network (or laptop connected to mobile hotspot — no mobile data needed).

### 3. Install Packages & Run

```bash
flutter pub get
flutter run
```

To build a release APK:
```bash
flutter build apk --release
```

---

## 📸 Screenshots

### Authentication & Onboarding
| | | | |
|---|---|---|---|
| ![](assets/images/1.png) | ![](assets/images/2.png) | ![](assets/images/3.png) | ![](assets/images/4.png) |
| ![](assets/images/5.png) | ![](assets/images/6.png) | ![](assets/images/7.png) | ![](assets/images/8.png) |


| | | | |
|---|---|---|---|
| ![](assets/images/9.png) | ![](assets/images/10.png) | ![](assets/images/11.png) | ![](assets/images/12.png) |
| ![](assets/images/13.png) | ![](assets/images/14.png) | ![](assets/images/15.png) | ![](assets/images/16.png) |


| | | | |
|---|---|---|---|
| ![](assets/images/17.png) | ![](assets/images/18.png) | ![](assets/images/19.png) | ![](assets/images/20.png) |
| ![](assets/images/21.png) | ![](assets/images/22.png) | ![](assets/images/23.png) | ![](assets/images/24.png) |


| | | | |
|---|---|---|---|
| ![](assets/images/25.png) | ![](assets/images/26.png) | ![](assets/images/27.png) | ![](assets/images/28.png) |
| ![](assets/images/29.png) | ![](assets/images/30.png) | ![](assets/images/31.png) | ![](assets/images/32.png) |


| | | | |
|---|---|---|---|
| ![](assets/images/33.png) | ![](assets/images/34.png) | ![](assets/images/35.png) | ![](assets/images/36.png) |
| ![](assets/images/37.png) | ![](assets/images/38.png) | | |

---

*Part of the BloodLink Unified Platform — Developed by Noor Mustafa*

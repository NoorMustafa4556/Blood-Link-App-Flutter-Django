# BloodLink - Smart Blood Donation App 🩸

**BloodLink** is a premium, high-performance platform designed to bridge the gap between blood donors and recipients. Built as a comprehensive Final Year Project (FYP), it features a robust **Django Backend & Web Portal** and a cross-platform **Flutter Mobile Application** that synchronize seamlessly in real-time.

---

## 📂 Repository Structure

The project is organized into two primary sub-projects:

*   📂 [**Blood Link Django/**](file:///c:/Users/NoorMustafa/Desktop/Fyp/Smart-Blood-Donation-App-Flutter-Django-main/Blood%20Link%20Django/) - The powerful Python-based REST API and Administrative/Web Portal.
*   📂 [**bloodlink_flutter/**](file:///c:/Users/NoorMustafa/Desktop/Fyp/Smart-Blood-Donation-App-Flutter-Django-main/bloodlink_flutter/) - The modern, cross-platform Dart mobile client for iOS and Android.

---

## 🌟 Platform Highlights

### 📱 Flutter Mobile Client
- **Dynamic Configuration Sync:** Reads dropdown items (Cities & Blood Groups) dynamically from the API, falling back to local files if offline.
- **Dual-Mode System:** Seamless role-switching between Donor and Recipient modes directly from the custom drawer.
- **Accurate Countdown Timer:** Displays remaining request times calculated from the server's timezone.
- **Robust Authentication:** Secure authentication using JWT tokens and automatic header injection.

### 💻 Django Backend & Admin Panel
- **Real-time Live Sync (Signals):** When cities or blood groups are added, edited, or deleted in the admin dashboard, Django automatically rewrites the Flutter `Constants.dart` file on the filesystem.
- **Filtered Management Views:** Dedicated templates to monitor active requests, manage lists, and audit user roles.
- **Automatic Seeding:** Database migrations automatically seed 22 major Pakistani cities and default blood groups upon deployment.
- **Superuser Isolation:** Excludes admin/superuser accounts from list metrics and donor stats for clean analytics.

---

## 🛠️ Technology Stack

| Layer | Technology | Details |
| :--- | :--- | :--- |
| **Backend Framework** | Django (Python) | High-level web framework for rapid development. |
| **Web API** | Django REST Framework | Clean RESTful endpoints and serializations. |
| **Mobile App** | Flutter (Dart) | Fast, responsive native compiled screens. |
| **State Management** | Provider | Reactive UI state and global data providers. |
| **Database** | SQLite (SQLite3) | Built-in database, pre-seeded with Pakistani cities. |
| **UI Design** | CSS3 & Material 3 | Modern cards, custom buttons, and elegant layouts. |

---

## 🚀 Step-by-Step Installation

### Step 1: Django Backend Setup
1. Open a terminal and navigate to the project directory:
   ```bash
   cd "Blood Link Django/myproject"
   ```
2. Install Python dependencies:
   ```bash
   pip install -r ../requirements.txt
   ```
3. Run database migrations (this will automatically seed default database entries):
   ```bash
   python manage.py migrate
   ```
4. Start the server (bind to `0.0.0.0` to expose it to your local Wi-Fi network):
   ```bash
   python manage.py runserver 0.0.0.0:8000
   ```

### Step 2: Flutter Mobile App Setup
1. Open a terminal and navigate to the Flutter project:
   ```bash
   cd bloodlink_flutter
   ```
2. Configure the Backend URL in `lib/utils/Config.dart` using your laptop's local IPv4 network address:
   ```dart
   static const String baseUrl = 'http://192.168.x.x:8000'; // Replace with your laptop IP
   ```
3. Get Flutter packages:
   ```bash
   flutter pub get
   ```
4. Run the project on an emulator or physical device:
   ```bash
   flutter run
   ```

---
*Developed by Noor Mustafa*

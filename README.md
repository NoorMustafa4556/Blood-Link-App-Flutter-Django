# BloodLink - Unified Blood Donation Platform 🩸

BloodLink is a premium, high-performance platform designed to bridge the gap between blood donors and recipients. It consists of a **Django Backend**, a **Web Portal**, and a **Flutter Mobile Application**, all working in perfect synchronization.

## 📂 Project Structure

This repository contains two main components:
*   [**Blood Link Django/**](file:///Blood%20Link%20Django/) - The powerful Backend API and Web Portal.
*   [**bloodlink_flutter/**](file:///bloodlink_flutter/) - The cross-platform Mobile App for iOS and Android.
*   
---
## 🚀 Quick Start Guide

### 1. Setup the Backend (Django)
1. Navigate to the Django directory:
   ```bash
   cd "Blood Link Django/myproject"
   ```
2. Install dependencies (if any) and run the server:
   ```bash
   python manage.py runserver 0.0.0.0:8000
   ```
3. Access the Web Portal at `http://localhost:8000`

### 2. Setup the Mobile App (Flutter)
1. Navigate to the Flutter directory:
   ```bash
   cd bloodlink_flutter
   ```
2. Ensure the API URL in `lib/utils/Config.dart` matches your local IP address.
3. Run the app:
   ```bash
   flutter run
   ```

---

## 🌟 Core Features

### 📱 Mobile App (Flutter)
- **Real-time Sync:** 5-second polling for instant request updates.
- **Smart Countdown:** Server-side calculated expiration timer.
- **Premium UI:** Modern design with smooth transitions and theme support.
- **Dual Role:** Switch between Donor and Recipient modes seamlessly.

### 💻 Web Portal (Django)
- **Interactive Dashboard:** Manage requests with dedicated detail pages.
- **Auto-Refresh:** Global synchronization without interrupting user forms.
- **Donor Search:** Filterable donor directory with city-wise tracking.

### 🛡️ Admin Panel
- **Advanced Analytics:** Visualized stats for users, donors, and requests.
- **Database Control:** Full management of cities and user records.

---

## 🛠️ Technology Stack
*   **Backend:** Django (Python), Django REST Framework
*   **Frontend (Web):** Vanilla HTML5, Modern CSS3, JavaScript
*   **Mobile:** Flutter (Dart), Provider (State Management)
*   **Database:** SQLite / PostgreSQL

---
*Developed by Noor Mustafa*

# 🩸 BloodLink – Smart Blood Donation Platform

**BloodLink** is a comprehensive, real-time blood donation management system built as a Final Year Project (FYP). It bridges the gap between blood donors and recipients through a beautifully designed **Flutter Mobile App** and a powerful **Django Web Portal + REST API** — both synchronized seamlessly in real-time.

When someone needs blood urgently, they should find the nearest available donor in just a few taps — **saving lives, one donation at a time.**

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white"/>
  <img src="https://img.shields.io/badge/Django-092E20?style=for-the-badge&logo=django&logoColor=white"/>
  <img src="https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white"/>
  <img src="https://img.shields.io/badge/Python-3776AB?style=for-the-badge&logo=python&logoColor=white"/>
  <img src="https://img.shields.io/badge/REST_API-FF6C37?style=for-the-badge&logo=postman&logoColor=white"/>
  <img src="https://img.shields.io/badge/SQLite-003B57?style=for-the-badge&logo=sqlite&logoColor=white"/>
</p>

---

## 📂 Repository Structure

```
Smart-Blood-Donation-App-Flutter-Django/
├── 📂 Blood Link Django/     → Django Backend, REST API & Admin Web Portal
└── 📂 bloodlink_flutter/     → Flutter Cross-Platform Mobile Application
```

---

## ❓ Why BloodLink?

Every year thousands of lives are lost due to unavailability of blood on time. BloodLink makes blood donation extremely easy and accessible. Donors register their blood group and location; recipients search and contact them directly — completely free, forever. The system is designed to work even without an active internet connection using intelligent offline fallbacks.

---

## 🌟 Key Features

### 📱 Mobile App (Flutter)
- **Dual-Mode Dashboard** – Separate experiences for Donors and Recipients with role-based navigation.
- **Real-Time Blood Requests** – 5-second background polling keeps dashboards live without manual refresh.
- **Smart Countdown Timers** – Each request shows exact minutes remaining before it expires.
- **Donor Discovery** – Search available donors by blood group and city with live API-backed filters.
- **JWT Authentication** – Secure login with auto-login on restart via `flutter_secure_storage`.
- **Full Profile Management** – Update name, phone, city, availability status, and profile picture.
- **Request History** – View all Sent and Received requests filtered by Pending / Accepted / Rejected.
- **Contact Privacy** – Phone and email hidden from others; revealed only after a request is accepted.
- **Dark / Light Theme** – Full theme toggle with persistent preference saving.
- **Dynamic Dropdowns** – Cities and blood groups fetched live from API, with offline fallback to `Constants.dart`.

### 💻 Web Portal & Admin Panel (Django)
- **Custom Admin Dashboard** – Stats cards for Total Users, Active Donors, Recipients, and Active Requests.
- **User Management** – Filter users by role (Donor/Recipient), view full profiles and activity logs.
- **Request Management** – View all blood requests platform-wide with full detail pages.
- **Manage Cities** – Add and delete Pakistani cities from admin UI — instantly syncs to mobile app.
- **Manage Blood Groups** – Add and delete blood groups — auto-rewrites Flutter `Constants.dart` via Django Signals.
- **Admin Profile Edit** – Admin can update their own name, email, phone, city, and profile picture.
- **Web User Portal** – Signup, Login, Home Dashboard, Profile, Donor Search, Send Request, and History pages.
- **Superuser Isolation** – Admin accounts excluded from donor/recipient stats and lists.
- **Auto Database Seeding** – On first `migrate`, seeds 22 Pakistani cities and 8 standard blood groups automatically.

---

## 🔄 System Workflow

```
Mobile App (Flutter)
       │
       └──► JWT Login ──► Django REST API
                               │
                    ┌──────────┼──────────┐
                    ▼          ▼          ▼
              Auth APIs   Request APIs  Search APIs
                               │
                    ┌──────────┘
                    ▼
              Django Signals
                    │
                    └──► Auto-rewrite Constants.dart
                          (on City / Blood Group change)
```

### Blood Request Lifecycle
```
Recipient Sends Request (Pending)
         │
         ├── Timer Countdown (1–5 hours)
         ▼
Donor Sees Request → Accept / Reject
         │
         ▼
Contact Revealed for 5 minutes (phone + email)
         │
         ▼
5 Donors Accept same patient → All remaining → "Fulfilled"
         │
         ▼
Expired requests → Auto-marked "Cancelled"
```

---

## 🛠️ Technology Stack

| Layer | Technology | Details |
|---|---|---|
| **Mobile Framework** | Flutter (Dart) | Cross-platform iOS & Android |
| **State Management** | Provider (ChangeNotifier) | Auth, requests, theme |
| **Backend Framework** | Django 5.x (Python) | REST API + Web Portal |
| **API Layer** | Django REST Framework | Serializers, permissions, JWT |
| **Authentication** | SimpleJWT | Stateless JWT token auth |
| **HTTP Client** | Dio (Flutter) | Interceptors for token injection |
| **CORS** | django-cors-headers | Flutter cross-origin support |
| **Image Upload** | Pillow (Django) | Profile picture processing |
| **Local Storage** | flutter_secure_storage | JWT + role persistence |
| **Database** | SQLite | Portable, auto-seeded |
| **Signals** | Django post_save/delete | Auto-sync Constants.dart |

---

## 🚀 Quick Start

### Backend (Django)
```bash
cd "Blood Link Django/myproject"
pip install -r ../requirements.txt
python manage.py migrate        # auto-seeds cities & blood groups
python manage.py createsuperuser
python manage.py runserver 0.0.0.0:8000
```
- Web Portal → `http://localhost:8000`
- Admin Panel → `http://localhost:8000/admin-panel/`

### Mobile App (Flutter)
```bash
cd bloodlink_flutter
# Set your laptop IP in lib/utils/Config.dart:
# static const String baseUrl = 'http://192.168.x.x:8000';
flutter pub get
flutter run
```

> **Viva Tip:** Turn on your mobile hotspot → connect laptop → run server with `0.0.0.0:8000` → install APK on phone. Everything works **without internet data**!

---

## 📸 App Screenshots – Mobile Application

<p align="center">
  <img src="https://raw.githubusercontent.com/NoorMustafa4556/Smart-Blood-Donation-App-Flutter-Django/main/bloodlink_flutter/assets/images/1.png" width="30%"/>
  <img src="https://raw.githubusercontent.com/NoorMustafa4556/Smart-Blood-Donation-App-Flutter-Django/main/bloodlink_flutter/assets/images/2.png" width="30%"/>
  <img src="https://raw.githubusercontent.com/NoorMustafa4556/Smart-Blood-Donation-App-Flutter-Django/main/bloodlink_flutter/assets/images/3.png" width="30%"/>
  <img src="https://raw.githubusercontent.com/NoorMustafa4556/Smart-Blood-Donation-App-Flutter-Django/main/bloodlink_flutter/assets/images/4.png" width="30%"/>
  <img src="https://raw.githubusercontent.com/NoorMustafa4556/Smart-Blood-Donation-App-Flutter-Django/main/bloodlink_flutter/assets/images/5.png" width="30%"/>
  <img src="https://raw.githubusercontent.com/NoorMustafa4556/Smart-Blood-Donation-App-Flutter-Django/main/bloodlink_flutter/assets/images/6.png" width="30%"/>
  <img src="https://raw.githubusercontent.com/NoorMustafa4556/Smart-Blood-Donation-App-Flutter-Django/main/bloodlink_flutter/assets/images/7.png" width="30%"/>
  <img src="https://raw.githubusercontent.com/NoorMustafa4556/Smart-Blood-Donation-App-Flutter-Django/main/bloodlink_flutter/assets/images/8.png" width="30%"/>
  <img src="https://raw.githubusercontent.com/NoorMustafa4556/Smart-Blood-Donation-App-Flutter-Django/main/bloodlink_flutter/assets/images/9.png" width="30%"/>
  <img src="https://raw.githubusercontent.com/NoorMustafa4556/Smart-Blood-Donation-App-Flutter-Django/main/bloodlink_flutter/assets/images/10.png" width="30%"/>
  <img src="https://raw.githubusercontent.com/NoorMustafa4556/Smart-Blood-Donation-App-Flutter-Django/main/bloodlink_flutter/assets/images/11.png" width="30%"/>
  <img src="https://raw.githubusercontent.com/NoorMustafa4556/Smart-Blood-Donation-App-Flutter-Django/main/bloodlink_flutter/assets/images/12.png" width="30%"/>
  <img src="https://raw.githubusercontent.com/NoorMustafa4556/Smart-Blood-Donation-App-Flutter-Django/main/bloodlink_flutter/assets/images/13.png" width="30%"/>
  <img src="https://raw.githubusercontent.com/NoorMustafa4556/Smart-Blood-Donation-App-Flutter-Django/main/bloodlink_flutter/assets/images/14.png" width="30%"/>
  <img src="https://raw.githubusercontent.com/NoorMustafa4556/Smart-Blood-Donation-App-Flutter-Django/main/bloodlink_flutter/assets/images/15.png" width="30%"/>
  <img src="https://raw.githubusercontent.com/NoorMustafa4556/Smart-Blood-Donation-App-Flutter-Django/main/bloodlink_flutter/assets/images/16.png" width="30%"/>
  <img src="https://raw.githubusercontent.com/NoorMustafa4556/Smart-Blood-Donation-App-Flutter-Django/main/bloodlink_flutter/assets/images/17.png" width="30%"/>
  <img src="https://raw.githubusercontent.com/NoorMustafa4556/Smart-Blood-Donation-App-Flutter-Django/main/bloodlink_flutter/assets/images/18.png" width="30%"/>
  <img src="https://raw.githubusercontent.com/NoorMustafa4556/Smart-Blood-Donation-App-Flutter-Django/main/bloodlink_flutter/assets/images/19.png" width="30%"/>
  <img src="https://raw.githubusercontent.com/NoorMustafa4556/Smart-Blood-Donation-App-Flutter-Django/main/bloodlink_flutter/assets/images/20.png" width="30%"/>
  <img src="https://raw.githubusercontent.com/NoorMustafa4556/Smart-Blood-Donation-App-Flutter-Django/main/bloodlink_flutter/assets/images/21.png" width="30%"/>
  <img src="https://raw.githubusercontent.com/NoorMustafa4556/Smart-Blood-Donation-App-Flutter-Django/main/bloodlink_flutter/assets/images/22.png" width="30%"/>
  <img src="https://raw.githubusercontent.com/NoorMustafa4556/Smart-Blood-Donation-App-Flutter-Django/main/bloodlink_flutter/assets/images/23.png" width="30%"/>
  <img src="https://raw.githubusercontent.com/NoorMustafa4556/Smart-Blood-Donation-App-Flutter-Django/main/bloodlink_flutter/assets/images/24.png" width="30%"/>
  <img src="https://raw.githubusercontent.com/NoorMustafa4556/Smart-Blood-Donation-App-Flutter-Django/main/bloodlink_flutter/assets/images/25.png" width="30%"/>
  <img src="https://raw.githubusercontent.com/NoorMustafa4556/Smart-Blood-Donation-App-Flutter-Django/main/bloodlink_flutter/assets/images/26.png" width="30%"/>
  <img src="https://raw.githubusercontent.com/NoorMustafa4556/Smart-Blood-Donation-App-Flutter-Django/main/bloodlink_flutter/assets/images/27.png" width="30%"/>
  <img src="https://raw.githubusercontent.com/NoorMustafa4556/Smart-Blood-Donation-App-Flutter-Django/main/bloodlink_flutter/assets/images/28.png" width="30%"/>
  <img src="https://raw.githubusercontent.com/NoorMustafa4556/Smart-Blood-Donation-App-Flutter-Django/main/bloodlink_flutter/assets/images/29.png" width="30%"/>
  <img src="https://raw.githubusercontent.com/NoorMustafa4556/Smart-Blood-Donation-App-Flutter-Django/main/bloodlink_flutter/assets/images/30.png" width="30%"/>
  <img src="https://raw.githubusercontent.com/NoorMustafa4556/Smart-Blood-Donation-App-Flutter-Django/main/bloodlink_flutter/assets/images/31.png" width="30%"/>
  <img src="https://raw.githubusercontent.com/NoorMustafa4556/Smart-Blood-Donation-App-Flutter-Django/main/bloodlink_flutter/assets/images/32.png" width="30%"/>
  <img src="https://raw.githubusercontent.com/NoorMustafa4556/Smart-Blood-Donation-App-Flutter-Django/main/bloodlink_flutter/assets/images/33.png" width="30%"/>
  <img src="https://raw.githubusercontent.com/NoorMustafa4556/Smart-Blood-Donation-App-Flutter-Django/main/bloodlink_flutter/assets/images/34.png" width="30%"/>
  <img src="https://raw.githubusercontent.com/NoorMustafa4556/Smart-Blood-Donation-App-Flutter-Django/main/bloodlink_flutter/assets/images/35.png" width="30%"/>
  <img src="https://raw.githubusercontent.com/NoorMustafa4556/Smart-Blood-Donation-App-Flutter-Django/main/bloodlink_flutter/assets/images/36.png" width="30%"/>
  <img src="https://raw.githubusercontent.com/NoorMustafa4556/Smart-Blood-Donation-App-Flutter-Django/main/bloodlink_flutter/assets/images/37.png" width="30%"/>
  <img src="https://raw.githubusercontent.com/NoorMustafa4556/Smart-Blood-Donation-App-Flutter-Django/main/bloodlink_flutter/assets/images/38.png" width="30%"/>
</p>

---

## 📸 App Screenshots – Web Portal & Admin Panel

<p align="center">
  <img src="https://github.com/NoorMustafa4556/Smart-Blood-Donation-App-Flutter-Django/blob/main/Blood%20Link%20Django/myproject/ProjectImages/1.png?raw=true" width="45%"/>
  <img src="https://github.com/NoorMustafa4556/Smart-Blood-Donation-App-Flutter-Django/blob/main/Blood%20Link%20Django/myproject/ProjectImages/2.png?raw=true" width="45%"/>
  <img src="https://github.com/NoorMustafa4556/Smart-Blood-Donation-App-Flutter-Django/blob/main/Blood%20Link%20Django/myproject/ProjectImages/3.png?raw=true" width="45%"/>
  <img src="https://github.com/NoorMustafa4556/Smart-Blood-Donation-App-Flutter-Django/blob/main/Blood%20Link%20Django/myproject/ProjectImages/4.png?raw=true" width="45%"/>
  <img src="https://github.com/NoorMustafa4556/Smart-Blood-Donation-App-Flutter-Django/blob/main/Blood%20Link%20Django/myproject/ProjectImages/5.png?raw=true" width="45%"/>
  <img src="https://github.com/NoorMustafa4556/Smart-Blood-Donation-App-Flutter-Django/blob/main/Blood%20Link%20Django/myproject/ProjectImages/6.png?raw=true" width="45%"/>
  <img src="https://github.com/NoorMustafa4556/Smart-Blood-Donation-App-Flutter-Django/blob/main/Blood%20Link%20Django/myproject/ProjectImages/7.png?raw=true" width="45%"/>
  <img src="https://github.com/NoorMustafa4556/Smart-Blood-Donation-App-Flutter-Django/blob/main/Blood%20Link%20Django/myproject/ProjectImages/8.png?raw=true" width="45%"/>
  <img src="https://github.com/NoorMustafa4556/Smart-Blood-Donation-App-Flutter-Django/blob/main/Blood%20Link%20Django/myproject/ProjectImages/9.png?raw=true" width="45%"/>
  <img src="https://github.com/NoorMustafa4556/Smart-Blood-Donation-App-Flutter-Django/blob/main/Blood%20Link%20Django/myproject/ProjectImages/10.png?raw=true" width="45%"/>
  <img src="https://github.com/NoorMustafa4556/Smart-Blood-Donation-App-Flutter-Django/blob/main/Blood%20Link%20Django/myproject/ProjectImages/11.png?raw=true" width="45%"/>
  <img src="https://github.com/NoorMustafa4556/Smart-Blood-Donation-App-Flutter-Django/blob/main/Blood%20Link%20Django/myproject/ProjectImages/12.png?raw=true" width="45%"/>
  <img src="https://github.com/NoorMustafa4556/Smart-Blood-Donation-App-Flutter-Django/blob/main/Blood%20Link%20Django/myproject/ProjectImages/14.png?raw=true" width="45%"/>
  <img src="https://github.com/NoorMustafa4556/Smart-Blood-Donation-App-Flutter-Django/blob/main/Blood%20Link%20Django/myproject/ProjectImages/15.png?raw=true" width="45%"/>
  <img src="https://github.com/NoorMustafa4556/Smart-Blood-Donation-App-Flutter-Django/blob/main/Blood%20Link%20Django/myproject/ProjectImages/16.png?raw=true" width="45%"/>
  <img src="https://github.com/NoorMustafa4556/Smart-Blood-Donation-App-Flutter-Django/blob/main/Blood%20Link%20Django/myproject/ProjectImages/17.png?raw=true" width="45%"/>
  <img src="https://github.com/NoorMustafa4556/Smart-Blood-Donation-App-Flutter-Django/blob/main/Blood%20Link%20Django/myproject/ProjectImages/18.png?raw=true" width="45%"/>
  <img src="https://github.com/NoorMustafa4556/Smart-Blood-Donation-App-Flutter-Django/blob/main/Blood%20Link%20Django/myproject/ProjectImages/19.png?raw=true" width="45%"/>
  <img src="https://github.com/NoorMustafa4556/Smart-Blood-Donation-App-Flutter-Django/blob/main/Blood%20Link%20Django/myproject/ProjectImages/20.png?raw=true" width="45%"/>
  <img src="https://github.com/NoorMustafa4556/Smart-Blood-Donation-App-Flutter-Django/blob/main/Blood%20Link%20Django/myproject/ProjectImages/21.png?raw=true" width="45%"/>
  <img src="https://github.com/NoorMustafa4556/Smart-Blood-Donation-App-Flutter-Django/blob/main/Blood%20Link%20Django/myproject/ProjectImages/22.png?raw=true" width="45%"/>
  <img src="https://github.com/NoorMustafa4556/Smart-Blood-Donation-App-Flutter-Django/blob/main/Blood%20Link%20Django/myproject/ProjectImages/23.png?raw=true" width="45%"/>
  <img src="https://github.com/NoorMustafa4556/Smart-Blood-Donation-App-Flutter-Django/blob/main/Blood%20Link%20Django/myproject/ProjectImages/24.png?raw=true" width="45%"/>
  <img src="https://github.com/NoorMustafa4556/Smart-Blood-Donation-App-Flutter-Django/blob/main/Blood%20Link%20Django/myproject/ProjectImages/25.png?raw=true" width="45%"/>
  <img src="https://github.com/NoorMustafa4556/Smart-Blood-Donation-App-Flutter-Django/blob/main/Blood%20Link%20Django/myproject/ProjectImages/26.png?raw=true" width="45%"/>
  <img src="https://github.com/NoorMustafa4556/Smart-Blood-Donation-App-Flutter-Django/blob/main/Blood%20Link%20Django/myproject/ProjectImages/27.png?raw=true" width="45%"/>
  <img src="https://github.com/NoorMustafa4556/Smart-Blood-Donation-App-Flutter-Django/blob/main/Blood%20Link%20Django/myproject/ProjectImages/28.png?raw=true" width="45%"/>
  <img src="https://github.com/NoorMustafa4556/Smart-Blood-Donation-App-Flutter-Django/blob/main/Blood%20Link%20Django/myproject/ProjectImages/29.png?raw=true" width="45%"/>
  <img src="https://github.com/NoorMustafa4556/Smart-Blood-Donation-App-Flutter-Django/blob/main/Blood%20Link%20Django/myproject/ProjectImages/30.png?raw=true" width="45%"/>
  <img src="https://github.com/NoorMustafa4556/Smart-Blood-Donation-App-Flutter-Django/blob/main/Blood%20Link%20Django/myproject/ProjectImages/31.png?raw=true" width="45%"/>
  <img src="https://github.com/NoorMustafa4556/Smart-Blood-Donation-App-Flutter-Django/blob/main/Blood%20Link%20Django/myproject/ProjectImages/32.png?raw=true" width="45%"/>
  <img src="https://github.com/NoorMustafa4556/Smart-Blood-Donation-App-Flutter-Django/blob/main/Blood%20Link%20Django/myproject/ProjectImages/33.png?raw=true" width="45%"/>
  <img src="https://github.com/NoorMustafa4556/Smart-Blood-Donation-App-Flutter-Django/blob/main/Blood%20Link%20Django/myproject/ProjectImages/34.png?raw=true" width="45%"/>
</p>

---

## 👨‍💻 Developer

### Hi, I'm Noor Mustafa 👋🏻

A passionate **Flutter Developer** and **Django Developer** from **Bahawalpur, Pakistan**, specializing in building elegant, scalable, and high-performance cross-platform applications. With a strong understanding of UI/UX principles, state management, and API integration, I aim to deliver apps that are not only functional but also user-centric and visually compelling.

**What I Do:**
- 🧑🏻‍💻 **Flutter App Development** – Cross-platform apps for Android, iOS, and the web.
- 🔗 **API Integration** – RESTful APIs, JWT Auth, Django REST Framework.
- 🎨 **UI/UX Design** – Responsive, animated interfaces with modern design systems.
- 🐍 **Django Backend** – REST APIs, custom admin dashboards, signal-based automation.
- ⚙️ **State Management** – Provider, ChangeNotifier for clean, scalable architecture.

<p align="left">
  <img src="https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white"/>
  <img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white"/>
  <img src="https://img.shields.io/badge/Python-3776AB?style=for-the-badge&logo=python&logoColor=white"/>
  <img src="https://img.shields.io/badge/Django-092E20?style=for-the-badge&logo=django&logoColor=white"/>
  <img src="https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black"/>
  <img src="https://img.shields.io/badge/GitHub-181717?style=for-the-badge&logo=github&logoColor=white"/>
  <img src="https://img.shields.io/badge/Postman-FF6C37?style=for-the-badge&logo=postman&logoColor=white"/>
</p>

**📫 Let's Connect:**

<p align="left">
  <a href="https://www.linkedin.com/in/noormustafa4556/" target="_blank">
    <img src="https://raw.githubusercontent.com/rahuldkjain/github-profile-readme-generator/master/src/images/icons/Social/linked-in-alt.svg" alt="LinkedIn" height="30" width="40"/>
  </a>
  <a href="https://github.com/NoorMustafa4556" target="_blank">
    <img src="https://img.shields.io/badge/GitHub-181717?style=flat&logo=github&logoColor=white" alt="GitHub" height="30"/>
  </a>
  <a href="https://www.facebook.com/NoorMustafa4556" target="_blank">
    <img src="https://raw.githubusercontent.com/rahuldkjain/github-profile-readme-generator/master/src/images/icons/Social/facebook.svg" alt="Facebook" height="30" width="40"/>
  </a>
  <a href="https://instagram.com/noormustafa4556" target="_blank">
    <img src="https://raw.githubusercontent.com/rahuldkjain/github-profile-readme-generator/master/src/images/icons/Social/instagram.svg" alt="Instagram" height="30" width="40"/>
  </a>
  <a href="https://wa.me/923087655076" target="_blank">
    <img src="https://raw.githubusercontent.com/rahuldkjain/github-profile-readme-generator/master/src/images/icons/Social/whatsapp.svg" alt="WhatsApp" height="30" width="40"/>
  </a>
  <a href="https://x.com/NoorMustafa4556" target="_blank">
    <img src="https://raw.githubusercontent.com/rahuldkjain/github-profile-readme-generator/master/src/images/icons/Social/twitter.svg" alt="X / Twitter" height="30" width="40"/>
  </a>
</p>

📍 **Location:** Bahawalpur, Punjab, Pakistan

---

> *"Learning never stops. Every app I build makes me a better developer — one widget at a time."*

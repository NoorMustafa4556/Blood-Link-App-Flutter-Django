# BloodLink Backend & Web Portal (Django) 💻

The core engine of the BloodLink platform, providing a robust API for mobile clients and a professional web portal for desktop users.

## ✨ Key Features
- **RESTful API:** Complete set of endpoints for authentication, request management, and user profiles.
- **Web Dashboard:** Dedicated pages for detailed blood request views.
- **Admin Command Center:** Powerful management interface for administrators.
- **Timezone Aware:** Server-side calculations for Pakistani Time (PKT).
- **Security:** CORS configured for Flutter Web compatibility.

## 🚀 Setup & Installation

### 1. Requirements
*   Python 3.10+
*   Django 5.0+
*   Django REST Framework
*   django-cors-headers

### 2. Run the Server
1. Navigate to the project root:
   ```bash
   cd myproject
   ```
2. Run migrations:
   ```bash
   python manage.py migrate
   ```
3. Start the development server:
   ```bash
   python manage.py runserver 0.0.0.0:8000
   ```

## 🔌 API Documentation
The API is designed to be consumed by the BloodLink Flutter app. Key endpoints include:
*   `/api/login/` - User Authentication
*   `/api/requests/my/` - Fetch user-specific requests
*   `/api/requests/update/` - Change request status

---
*Developed with Django & Python*

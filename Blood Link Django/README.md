# BloodLink Backend & Web Portal (Django) 💻

This is the core server engine of the BloodLink platform. It provides the REST API endpoints consumed by the Flutter mobile application and includes an Administrative Dashboard UI for blood donation system management.

---

## ✨ Features & Capabilities

- **RESTful Endpoints:** Complete API for signups, profile updates, city lists, blood group lists, and requests.
- **Django Signals (Flutter Code Generator):** Listens to database events (`City` & `BloodGroup`) and automatically generates `Constants.dart` in the Flutter directory on edit/add/delete actions.
- **Role Isolation:** Filters out superusers and administrative roles from normal user registries (donors and recipients).
- **Custom Admin Interface:** Beautiful custom-styled pages to manage cities, blood groups, and view activity logs.
- **Security Protocols:** Properly configured CORS (Cross-Origin Resource Sharing) middleware to prevent blocked cross-origin mobile and web requests.

---

## 🛠️ API Reference Endpoints

| Endpoint | Method | Description |
| :--- | :--- | :--- |
| `/api/login/` | `POST` | User authentication returning simple JWT tokens. |
| `/api/register/` | `POST` | Standard user registration form. |
| `/api/cities/` | `GET` | Retrieve list of active Pakistani cities. |
| `/api/blood-groups/` | `GET` | Retrieve list of registered blood groups. |
| `/api/requests/send/` | `POST` | Create a new urgent blood request. |
| `/api/requests/my/` | `GET` | View user's sent or received blood requests. |

---

## 🚀 Setup & Execution

### 1. Requirements
Ensure you have the following installed in your system:
- Python 3.10+
- Django 5.x+
- Pillow (for image uploads)
- django-cors-headers

### 2. Quickstart Commands
Navigate to the `myproject` root:
```bash
cd myproject
```

Install packages:
```bash
pip install -r ../requirements.txt
```

Run migrations (Seeds default Pakistani cities & standard blood groups):
```bash
python manage.py migrate
```

Create a Superuser (Admin account):
```bash
python manage.py createsuperuser
```

Run server:
```bash
python manage.py runserver 0.0.0.0:8000
```
- Access Admin Panel Dashboard at: `http://localhost:8000/admin-panel/`

---
*Part of the BloodLink Unified Platform*

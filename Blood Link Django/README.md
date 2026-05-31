# BloodLink Backend & Web Portal (Django) 💻

The core server engine of the BloodLink platform — providing a complete REST API for the Flutter mobile app and a beautifully designed Admin & Web Portal for system management.

---

## 📋 Table of Contents

- [Overview](#overview)
- [Features](#features)
- [System Workflow](#system-workflow)
- [Architecture](#architecture)
- [API Reference](#api-reference)
- [Admin Panel](#admin-panel)
- [Database Models](#database-models)
- [Setup & Installation](#setup--installation)
- [Screenshots](#screenshots)

---

## 🔍 Overview

BloodLink Django is built with Python and Django REST Framework. It manages all authentication, user profiles, blood request lifecycle, and exposes a clean REST API consumed by the Flutter mobile app. It also includes a fully custom Admin Panel with its own styled UI (separate from Django's default admin).

---

## ✨ Features

### 🔌 REST API
- JWT authentication (`djangorestframework-simplejwt`).
- User registration and profile management endpoints.
- Blood request create, update, and status change endpoints.
- Dynamic city and blood group list endpoints.
- Donor search with blood group and city filters.

### 🛡️ Custom Admin Panel
- **Dashboard:** View total users, active donors, recipients, and active requests at a glance via metric cards.
- **User Management:** View all users, filter by role (Donor/Recipient), click to inspect any user's full profile and activity log.
- **Request Management:** View all blood requests, see detailed request info, request status.
- **Manage Cities:** Add and delete Pakistani cities directly from the admin UI — changes reflect instantly in the mobile app dropdown.
- **Manage Blood Groups:** Add and delete blood groups — changes auto-update the Flutter `Constants.dart` file via Django Signals.
- **Admin Profile Edit:** Admin can update their own name, email, phone, city, blood group, and profile picture from a dedicated custom UI page.
- **Superuser Isolation:** Admin accounts are excluded from user statistics and donor/recipient lists.

### 🔄 Auto-Sync (Django Signals)
- When any City or Blood Group is **added, edited, or deleted**, Django automatically rewrites the Flutter `Constants.dart` file on the local filesystem.
- This means changes made via the Admin Panel are reflected in the mobile app's offline fallback list without any manual file editing.

### 🌐 Web Portal (for Users)
- Landing page, Login, and Sign Up.
- User home dashboard with blood request viewing.
- Profile page with edit functionality.
- Donor search by city and blood group.
- Send blood request form with all fields.
- Request history with status tracking.

### 🗄️ Database Seeding
- On first migration (`python manage.py migrate`), the system automatically seeds:
  - **22 major Pakistani cities** (Lahore, Karachi, Islamabad, etc.)
  - **8 standard blood groups** (A+, A−, B+, B−, O+, O−, AB+, AB−)

---

## 🔄 System Workflow

```
Mobile / Web Client
       │
       ▼
  JWT Login ─────────────► User Authenticated
       │
       ▼
 API Request (e.g. GET /api/requests/my/)
       │
       ▼
  Permission Check (IsAuthenticated)
       │
       ▼
   View Function (api_views.py)
       │
       ├──► Serializer (serializers.py)
       │          │
       │          └──► Context: 'user' key controls
       │                 phone/email privacy visibility
       │
       └──► Database Query (models.py)
                  │
                  └──► Django Signal (post_save / post_delete)
                             │
                             └──► Constants.dart auto-rewrite
                                   (if City or BloodGroup changed)
```

### Blood Request Lifecycle
```
Recipient Sends Request (status=Pending)
          │
          ├── Timer Running (1–5 hours based on duration)
          │
          ▼
Donor Sees Request on Home Screen
          │
     ┌────┴────┐
     ▼         ▼
  Accept      Reject
     │
     ▼
Contact Revealed (phone/email visible for 5 minutes)
     │
     ▼
After 5 Accepts for same patient → All Pending marked "Fulfilled"
```

---

## 🏗️ Architecture

| Layer | Technology | Details |
|---|---|---|
| **Framework** | Django 5.x | Web + REST backend |
| **API Layer** | Django REST Framework | Serializers, ViewSets, Permissions |
| **Auth** | SimpleJWT | Access tokens in HTTP headers |
| **CORS** | django-cors-headers | Flutter web & mobile cross-origin support |
| **Images** | Pillow | Profile picture upload and resizing |
| **Database** | SQLite (SQLite3) | Portable, pre-seeded with defaults |
| **Signals** | Django post_save / post_delete | Auto-sync Constants.dart on model changes |

---

## 🔌 API Reference

### Authentication
| Method | Endpoint | Description |
|---|---|---|
| `POST` | `/api/login/` | Login — returns JWT access token + full user profile |
| `POST` | `/api/register/` | Register new user with role (donor/recipient) |

### User & Profile
| Method | Endpoint | Description |
|---|---|---|
| `POST` | `/api/update-profile/` | Update name, phone, city, availability, image |
| `POST` | `/api/verify-password/` | Verify current password before change |
| `POST` | `/api/change-password/` | Change account password |

### Blood Requests
| Method | Endpoint | Description |
|---|---|---|
| `POST` | `/api/requests/send/` | Send a new blood request to a donor |
| `GET` | `/api/requests/my/` | Get user's sent or received requests |
| `POST` | `/api/requests/update/` | Accept or Reject a request (donor only) |
| `POST` | `/api/requests/acknowledge/` | Mark a request as seen/acknowledged |

### Dynamic Lists
| Method | Endpoint | Description |
|---|---|---|
| `GET` | `/api/cities/` | Get all active Pakistani cities |
| `GET` | `/api/blood-groups/` | Get all active blood groups |
| `GET` | `/api/donors/` | Search donors by blood group and city |

---

## 🛡️ Admin Panel Pages

| Page | URL | Description |
|---|---|---|
| Admin Login | `/admin-panel/login/` | Secure admin login |
| Dashboard | `/admin-panel/` | Stats overview with metric cards |
| All Users | `/admin-panel/users/` | Filterable user list (all / donor / recipient) |
| User Detail | `/admin-panel/users/<id>/` | Profile, activity log, request history |
| All Requests | `/admin-panel/requests/` | All platform blood requests |
| Request Detail | `/admin-panel/requests/<id>/` | Full request info |
| Manage Cities | `/admin-panel/cities/` | Add & delete cities |
| Manage Blood Groups | `/admin-panel/blood-groups/` | Add & delete blood groups |
| Admin Profile Edit | `/admin-panel/profile/` | Admin's own profile and picture |

---

## 🗄️ Database Models

### `Profile`
Extends Django's built-in `User` model via OneToOne relationship.
| Field | Type | Description |
|---|---|---|
| `image` | ImageField | Profile picture |
| `phone_number` | CharField | Contact number |
| `blood_group` | CharField | e.g. A+, B− |
| `city` | CharField | User's city |
| `is_donor` | BooleanField | True = Donor, False = Recipient |
| `available` | BooleanField | Donor availability toggle |

### `BloodRequest`
| Field | Type | Description |
|---|---|---|
| `sender` | FK(User) | The recipient who sent the request |
| `receiver` | FK(User) | The targeted donor |
| `patient_name` | CharField | Patient's name |
| `blood_group` | CharField | Required blood group |
| `city` | CharField | City of the hospital |
| `hospital_name` | CharField | Name of the hospital |
| `message` | TextField | Additional info/urgency message |
| `status` | CharField | Pending / Accepted / Rejected / Cancelled / Fulfilled |
| `duration` | IntegerField | Hours the request stays active |
| `accepted_at` | DateTimeField | Timestamp when donor accepted |
| `donor_response` | TextField | Donor's message + contact info |

### `City` & `BloodGroup`
Standalone models managed from Admin Panel. Changes trigger `Constants.dart` rewrite via Django Signals.

---

## 🚀 Setup & Installation

### 1. Navigate to project
```bash
cd "Blood Link Django/myproject"
```

### 2. Install dependencies
```bash
pip install -r ../requirements.txt
```

### 3. Run migrations (auto-seeds cities & blood groups)
```bash
python manage.py migrate
```

### 4. Create admin account
```bash
python manage.py createsuperuser
```

### 5. Start server (expose to local network)
```bash
python manage.py runserver 0.0.0.0:8000
```

- Web Portal: `http://localhost:8000`
- Admin Panel: `http://localhost:8000/admin-panel/`
- Django Default Admin: `http://localhost:8000/admin/`

---

## 📸 Screenshots

### Landing & Authentication
| | | | |
|---|---|---|---|
| ![](ProjectImages/1.png) | ![](ProjectImages/2.png) | ![](ProjectImages/3.png) | ![](ProjectImages/4.png) |

### Web Portal – User Screens
| | | | |
|---|---|---|---|
| ![](ProjectImages/5.png) | ![](ProjectImages/6.png) | ![](ProjectImages/7.png) | ![](ProjectImages/8.png) |
| ![](ProjectImages/9.png) | ![](ProjectImages/10.png) | ![](ProjectImages/11.png) | ![](ProjectImages/12.png) |

### Web Portal – Requests & Search
| | | | |
|---|---|---|---|
| ![](ProjectImages/14.png) | ![](ProjectImages/15.png) | ![](ProjectImages/16.png) | ![](ProjectImages/17.png) |
| ![](ProjectImages/18.png) | ![](ProjectImages/19.png) | ![](ProjectImages/20.png) | ![](ProjectImages/21.png) |

### Admin Dashboard & Management
| | | | |
|---|---|---|---|
| ![](ProjectImages/22.png) | ![](ProjectImages/23.png) | ![](ProjectImages/24.png) | ![](ProjectImages/25.png) |
| ![](ProjectImages/26.png) | ![](ProjectImages/27.png) | ![](ProjectImages/28.png) | ![](ProjectImages/29.png) |

### Admin Users, Requests & Settings
| | | | |
|---|---|---|---|
| ![](ProjectImages/30.png) | ![](ProjectImages/31.png) | ![](ProjectImages/32.png) | ![](ProjectImages/33.png) |
| ![](ProjectImages/34.png) | | | |

---

*Part of the BloodLink Unified Platform — Developed by Noor Mustafa*

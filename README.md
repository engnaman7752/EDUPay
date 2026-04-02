# EduPay AI — Intelligent School Fee Management System

<p align="center">
  <strong>🤖 AI-Powered Chat &nbsp;•&nbsp; ⚡ Real-Time Notifications &nbsp;•&nbsp; 💳 Smart Fee Management &nbsp;•&nbsp; 📊 Finance Dashboard</strong>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Spring%20Boot-3.5.4-6DB33F?logo=springboot&logoColor=white" />
  <img src="https://img.shields.io/badge/Gemini-2.0%20Flash-4285F4?logo=google&logoColor=white" />
  <img src="https://img.shields.io/badge/Flutter-3.0+-02569B?logo=flutter&logoColor=white" />
  <img src="https://img.shields.io/badge/PostgreSQL-pgvector-4169E1?logo=postgresql&logoColor=white" />
  <img src="https://img.shields.io/badge/JWT-Auth-000000?logo=jsonwebtokens&logoColor=white" />
</p>

---

## 📚 Overview

EduPay AI is a **full-stack intelligent school fee management system** built for a school manager to oversee every aspect of institutional finances. It combines:

- A **Flutter mobile app** for students and admins
- A **Spring Boot 3 backend** with JWT security, WebSocket notifications, and an AI chat assistant
- A **Finance Dashboard** backend with role-based access (Viewer → Analyst → Admin), financial record tracking, and real-time aggregate summaries — built as part of a backend engineering assignment

> **Internship Assignment Note**: The finance dashboard module (`/api/financial-records`, `/api/dashboard`, `/api/users`) was designed and implemented as a backend engineering assessment. It demonstrates API design, data modelling, RBAC access control, and aggregated analytics — all layered on top of the existing EduPay system.

---

## ✨ What Makes This Special

| Feature | How It Works |
|---------|-------------|
| **🤖 AI Chat** | Students ask questions → Gemini generates a grounded, personalized answer with their fee context |
| **⚡ Real-Time Notifications** | AI drafts personalized fee reminders → Pushed instantly via STOMP WebSocket |
| **🔒 Role-Based Access Control** | Three-tier RBAC: `VIEWER`, `ANALYST`, `ADMIN` with endpoint-level enforcement |
| **📊 Finance Dashboard** | Total income, expenses, net balance, category-wise splits, and recent activity |
| **🔄 Gemini Key Rotation** | Round-robin across multiple API keys for sustained AI throughput during development |
| **💎 Premium Flutter UI** | Dark glassmorphism theme, animated chat bubbles, typing indicators, gradient cards |

---

## 🏗️ System Architecture

```
┌────────────────────────────────────────────────────────────────┐
│                       FLUTTER MOBILE APP                        │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────────────┐  │
│  │  AI Chat      │  │  Dashboard   │  │  Real-Time           │  │
│  │  Screen       │  │  (Fees +     │  │  Notifications       │  │
│  │               │  │  Finance)    │  │  (WebSocket Stream)  │  │
│  └──────┬───────┘  └──────┬───────┘  └──────────┬───────────┘  │
└─────────┼─────────────────┼──────────────────────┼─────────────┘
          │ REST + JWT       │                      │ STOMP/WebSocket
          ▼                  ▼                      ▼
┌────────────────────────────────────────────────────────────────┐
│                    SPRING BOOT 3 BACKEND                        │
│  ┌────────────┐  ┌────────────┐  ┌───────────┐  ┌───────────┐  │
│  │ AIService  │  │ Dashboard  │  │ Financial │  │Notification│  │
│  │ (Gemini +  │  │ Service    │  │ Records   │  │ Service   │  │
│  │ Key Pool)  │  │ (Summaries)│  │ CRUD API  │  │ WS Push   │  │
│  └──────┬─────┘  └──────┬─────┘  └─────┬─────┘  └─────┬─────┘  │
└─────────┼───────────────┼──────────────┼───────────────┼────────┘
          │               │              │               │
          ▼               ▼              ▼               ▼
   ┌─────────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐
   │ GeminiKey   │  │PostgreSQL│  │ JPA Repo │  │  STOMP   │
   │ Rotator     │  │+ pgvector│  │          │  │  Broker  │
   │ (Round-Robin│  │          │  │          │  │          │
   │  4 Keys)    │  │          │  │          │  │          │
   └─────────────┘  └──────────┘  └──────────┘  └──────────┘
```

---

## 🚀 Tech Stack

### Backend
| Technology | Purpose |
|-----------|---------|
| **Spring Boot 3.5.4** | Core framework (Java 21+) |
| **Spring Security + JWT** | Stateless authentication & RBAC authorization |
| **Google Gemini 2.0 Flash** | Large Language Model for AI responses |
| **GeminiKeyRotator** | Thread-safe round-robin API key pool for dev throughput |
| **PostgreSQL + pgvector** | Relational database + vector similarity for RAG |
| **Spring Data JPA + Hibernate** | ORM with schema auto-creation |
| **STOMP WebSocket** | Real-time bidirectional notification push |
| **Lombok** | Boilerplate reduction |
| **Apache Tika** | PDF document parsing for RAG ingestion |

### Frontend
| Technology | Purpose |
|-----------|---------|
| **Flutter (Dart 3.0+)** | Cross-platform mobile framework |
| **Riverpod 2.6** | State management |
| **stomp_dart_client** | STOMP WebSocket client |
| **flutter_markdown** | Render AI markdown responses |
| **animated_text_kit** | Typewriter effects for AI responses |
| **Material 3 + Google Fonts** | Premium dark UI system |

---

## 📁 Project Structure

```
EDUPay-1/
├── backend/
│   └── src/main/java/com/EduPay/
│       ├── config/
│       │   ├── GeminiKeyRotator.java      # ★ Round-robin API key pool
│       │   ├── SecurityConfig.java        # JWT + 3-tier RBAC rules
│       │   ├── CustomUserDetails.java     # Status-aware user details
│       │   ├── JwtAuthFilter.java         # JWT request filter
│       │   ├── WebSocketConfig.java       # STOMP broker
│       │   └── WebConfig.java             # CORS
│       ├── controller/
│       │   ├── FinancialRecordController.java  # ★ Finance CRUD + filtering
│       │   ├── DashboardController.java        # ★ Summary analytics API
│       │   ├── UserManagementController.java   # ★ User + role management
│       │   ├── ChatController.java             # AI chat endpoint
│       │   ├── AdminController.java            # Student & fee management
│       │   ├── StudentController.java          # Student-facing endpoints
│       │   └── NotificationController.java     # Notification CRUD + triggers
│       ├── service/
│       │   ├── AIService.java             # ★ Gemini calls via key rotator
│       │   ├── DashboardService.java      # ★ Aggregate income/expense/balance
│       │   ├── NotificationService.java   # Scheduled AI reminders + WS push
│       │   ├── AuthService.java           # Login + admin registration
│       │   ├── FeeService.java            # Fee CRUD
│       │   ├── PaymentService.java        # Payment processing
│       │   └── StudentService.java        # Student management
│       ├── model/
│       │   ├── FinancialRecord.java       # ★ Income/Expense records
│       │   ├── User.java                  # ★ Users with role + status
│       │   ├── Student.java               # Student entity
│       │   ├── Fee.java                   # Fee entity
│       │   ├── Payment.java               # Payment entity
│       │   ├── Notification.java          # Notification entity
│       │   └── Announcement.java          # Announcement entity
│       └── repository/
│           ├── FinancialRecordRepository.java  # ★ Filter by type/category/date
│           ├── UserRepository.java
│           ├── StudentRepository.java
│           ├── FeeRepository.java
│           └── NotificationRepository.java
│
├── frontend/edupay/lib/
│   ├── features/
│   │   ├── ai_chat/views/chat_screen.dart
│   │   └── dashboard/widgets/
│   ├── services/
│   ├── models/
│   ├── screens/auth, admin, student/
│   └── main.dart
│
└── README.md
```
*(★ = added/modified as part of the finance dashboard assignment)*

---

## 🔐 Role-Based Access Control

Three user roles are enforced at the HTTP security layer:

| Role | Permissions |
|------|------------|
| `VIEWER` | Read-only access to dashboard summaries and financial records |
| `ANALYST` | Read records, view dashboard summaries |
| `ADMIN` | Full CRUD on financial records, users, students, fees, announcements |

Roles are stored in the `users` table, assigned by an admin via `PUT /api/users/{id}/role`, and enforced by Spring Security's `hasRole()` / `hasAnyRole()` matchers.

Users can also be set to `ACTIVE` or `INACTIVE`. Inactive users are rejected by `CustomUserDetails.isEnabled()` before any request is processed.

---

## 📊 Finance Dashboard (Assignment Module)

### Financial Records
Each record tracks a single school financial event:

| Field | Type | Description |
|-------|------|-------------|
| `amount` | BigDecimal | Transaction value |
| `type` | String | `INCOME` or `EXPENSE` |
| `category` | String | `FEES`, `SALARY`, `MAINTENANCE`, `EVENTS`, `OTHERS` |
| `recordDate` | LocalDate | Date of transaction |
| `notes` | String | Free-text description |

### Dashboard Summary (`GET /api/dashboard/summary`)
Returns a single JSON object with:
- `totalIncome` — Sum of all INCOME records
- `totalExpenses` — Sum of all EXPENSE records
- `netBalance` — `totalIncome - totalExpenses`
- `categoryTotals` — Map of category → total amount
- `recentActivity` — Last 10 records sorted by date (newest first)

---

## 🔄 Gemini Key Rotation

To avoid rate-limiting during development, the backend uses a **thread-safe round-robin key pool**:

```yaml
# application.yml
edupay:
  ai:
    api-keys: KEY_1,KEY_2,KEY_3,KEY_4
```

```java
// GeminiKeyRotator.java — picks next key atomically per request
public String nextKey() {
    int i = index.getAndUpdate(current -> (current + 1) % apiKeys.size());
    return apiKeys.get(i);
}
```

Each inbound AI request (chat or notice generation) gets the next key in sequence:
```
Request 1 → Key 0
Request 2 → Key 1
Request 3 → Key 2
Request 4 → Key 3
Request 5 → Key 0  ← wraps around
```

> ⚠️ **Note**: This setup is intended for development only. For production, use a single paid-tier API key with proper billing enabled on your Google Cloud Project.

---

## 🛠️ Setup and Installation

### Prerequisites
- **Java 21+** (JDK)
- **Flutter SDK 3.0+**
- **PostgreSQL 12+** with `pgvector` extension
- **Maven 3.6+** (or use the included `mvnw` wrapper)
- **Google AI Studio API Key(s)** — free tier at [aistudio.google.com](https://aistudio.google.com)

### 1. Database Setup

```bash
# Create the database
createdb edupay_db

# Enable pgvector extension
psql edupay_db -c "CREATE EXTENSION IF NOT EXISTS vector;"
```

### 2. Backend Configuration

Edit `backend/src/main/resources/application.yml`:

```yaml
spring:
  datasource:
    password: YOUR_POSTGRES_PASSWORD   # ← change this

edupay:
  ai:
    api-keys: YOUR_GEMINI_KEY_1,YOUR_GEMINI_KEY_2   # ← add your key(s)

jwt:
  secret: YOUR_STRONG_256BIT_SECRET   # ← change this
```

> **First Run**: `ddl-auto: create` will drop and recreate all tables on startup. Change to `ddl-auto: update` after the first run to preserve your data.

### 3. Run the Backend

```bash
cd backend
./mvnw clean compile
./mvnw spring-boot:run
```

Backend runs on: `http://localhost:8081`

### 4. Register Your First Admin

```http
POST http://localhost:8081/api/auth/register/admin
Content-Type: application/json

{ "username": "admin", "password": "admin123" }
```

### 5. Frontend Setup

```bash
cd frontend/edupay
flutter pub get
flutter run
```

---

## 📱 API Endpoints

### Authentication
| Method | Endpoint | Access | Description |
|--------|----------|--------|-------------|
| `POST` | `/api/auth/register/admin` | Public | Register a new admin |
| `POST` | `/api/auth/login` | Public | Login (returns JWT) |

### User Management
| Method | Endpoint | Access | Description |
|--------|----------|--------|-------------|
| `GET` | `/api/users` | ADMIN | List all users |
| `POST` | `/api/users` | ADMIN | Create a new user |
| `PUT` | `/api/users/{id}/role` | ADMIN | Update user role |
| `PUT` | `/api/users/{id}/status` | ADMIN | Activate / deactivate user |

### Financial Records
| Method | Endpoint | Access | Description |
|--------|----------|--------|-------------|
| `GET` | `/api/financial-records` | ALL ROLES | List records (filter by `?type=`, `?category=`, `?startDate=&endDate=`) |
| `POST` | `/api/financial-records` | ADMIN | Create a new record |
| `PUT` | `/api/financial-records/{id}` | ADMIN | Update a record |
| `DELETE` | `/api/financial-records/{id}` | ADMIN | Delete a record |

### Dashboard
| Method | Endpoint | Access | Description |
|--------|----------|--------|-------------|
| `GET` | `/api/dashboard/summary` | ALL ROLES | Income, expenses, balance, category totals, recent activity |

### AI Chat
| Method | Endpoint | Access | Description |
|--------|----------|--------|-------------|
| `POST` | `/api/ai/chat` | Authenticated | Ask AI a question (scoped to your student data) |

### Notifications
| Method | Endpoint | Access | Description |
|--------|----------|--------|-------------|
| `GET` | `/api/notifications` | Authenticated | Fetch user notifications |
| `PUT` | `/api/notifications/{id}/read` | Authenticated | Mark as read |
| `POST` | `/api/admin/notifications/trigger` | ADMIN | Trigger AI fee reminders |

### WebSocket
| Protocol | Endpoint | Description |
|----------|----------|-------------|
| `STOMP` | `/ws` | WebSocket handshake (SockJS) |
| Subscribe | `/topic/notifications/{userId}` | Real-time notification stream |

---

## 🌐 Deployment

### Backend (Railway / Render)
Set these environment variables on your platform:

```
SPRING_DATASOURCE_URL=jdbc:postgresql://host/edupay_db
SPRING_DATASOURCE_USERNAME=postgres
SPRING_DATASOURCE_PASSWORD=...
EDUPAY_AI_API_KEYS=key1,key2,key3
JWT_SECRET=...
```

### Frontend
```bash
flutter build apk    # Android
flutter build ios    # iOS
```

---

## 👨‍💻 Author

**Naman Jain**
- Email: [nj260106@gmail.com](mailto:nj260106@gmail.com)
- GitHub: [@engnaman7752](https://github.com/engnaman7752)

---

## 📄 License

This project is licensed under the MIT License.

---

<p align="center">
  <strong>Built with ❤️ using Spring Boot, Gemini 2.0 Flash, pgvector & Flutter</strong>
</p>

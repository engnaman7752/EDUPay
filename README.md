# EduPay AI — Intelligent School Fee Management System

<p align="center">
  <strong>🤖 AI-Powered Chat (RAG) &nbsp;•&nbsp; ⚡ Real-Time WebSocket Notifications &nbsp;•&nbsp; 💳 Smart Fee Management</strong>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Spring%20Boot-3.5.4-6DB33F?logo=springboot&logoColor=white" />
  <img src="https://img.shields.io/badge/Spring%20AI-1.0.0-6DB33F?logo=spring&logoColor=white" />
  <img src="https://img.shields.io/badge/Gemini-2.0%20Flash-4285F4?logo=google&logoColor=white" />
  <img src="https://img.shields.io/badge/Flutter-3.0+-02569B?logo=flutter&logoColor=white" />
  <img src="https://img.shields.io/badge/PostgreSQL-pgvector-4169E1?logo=postgresql&logoColor=white" />
</p>

---

## 📚 Overview

EduPay AI transforms traditional school fee management into an **intelligent, real-time assistant**. Parents chat with an AI that understands school policies (via RAG), receive personalized fee reminders drafted by GenAI, and get instant notifications pushed through WebSockets — all secured with JWT authentication.

### ✨ What Makes This Special

| Feature | How It Works |
|---------|-------------|
| **🤖 AI Chat (RAG)** | Parents ask questions → pgvector similarity search finds relevant school policy → Gemini generates a grounded answer with source citations |
| **⚡ Real-Time Notifications** | System detects pending fees → AI drafts a polite, personalized reminder → Pushed instantly via STOMP WebSocket |
| **🔒 Scoped AI Context** | JWT ensures the AI only sees and discusses data belonging to the logged-in parent's child |
| **💎 Premium Flutter UI** | Dark glassmorphism theme, animated chat bubbles, typing indicators, gradient cards |

---

## 🏗️ System Architecture

```
┌──────────────────────────────────────────────────────────────┐
│                    FLUTTER MOBILE APP                         │
│  ┌──────────────┐  ┌──────────────┐  ┌────────────────────┐  │
│  │  AI Chat      │  │  Smart       │  │  Real-Time         │  │
│  │  Screen       │  │  Dashboard   │  │  Notifications     │  │
│  │  (Markdown +  │  │  (Fee Card + │  │  (AnimatedList +   │  │
│  │  Source Tags) │  │  AI Insight) │  │  WebSocket Stream) │  │
│  └──────┬───────┘  └──────┬───────┘  └────────┬───────────┘  │
└─────────┼─────────────────┼───────────────────┼──────────────┘
          │ REST + JWT      │                   │ STOMP/WebSocket
          ▼                 ▼                   ▼
┌──────────────────────────────────────────────────────────────┐
│                  SPRING BOOT 3 BACKEND                        │
│  ┌──────────────┐  ┌──────────────┐  ┌────────────────────┐  │
│  │  AIService    │  │  Notification│  │  Fee/Payment       │  │
│  │  (RAG Logic)  │  │  Service     │  │  Management        │  │
│  │  Similarity   │  │  AI-Drafted  │  │  CRUD + Razorpay   │  │
│  │  Search +     │  │  Reminders + │  │                    │  │
│  │  Gemini Call  │  │  WS Push     │  │                    │  │
│  └──────┬───────┘  └──────┬───────┘  └────────┬───────────┘  │
└─────────┼─────────────────┼───────────────────┼──────────────┘
          │ Spring AI       │                   │ JPA
          ▼                 ▼                   ▼
┌─────────────────┐  ┌─────────────┐  ┌─────────────────────┐
│  Google Gemini   │  │  STOMP      │  │  PostgreSQL         │
│  2.0 Flash       │  │  Broker     │  │  + pgvector         │
│  (LLM)           │  │  /topic     │  │  (Vector Store)     │
└─────────────────┘  │  /queue     │  └─────────────────────┘
                     └─────────────┘

         RAG PIPELINE (On Startup)
  ┌──────────┐    ┌──────────┐    ┌──────────┐    ┌──────────┐
  │  School   │───▶│  Tika    │───▶│  Token   │───▶│ pgvector │
  │  Handbook │    │  Reader  │    │ Splitter │    │Embeddings│
  │  (PDF)    │    │          │    │          │    │          │
  └──────────┘    └──────────┘    └──────────┘    └──────────┘
```

---

## 🚀 Tech Stack

### Backend
| Technology | Purpose |
|-----------|---------|
| **Spring Boot 3.5.4** | Core framework (Java 24) |
| **Spring AI 1.0.0** | LLM orchestration + vector store integration |
| **Google Gemini 2.0 Flash** | Large Language Model for AI responses |
| **PostgreSQL + pgvector** | Database + vector similarity search for RAG |
| **STOMP WebSocket** | Real-time bidirectional notification push |
| **Spring Security + JWT** | Authentication & role-based authorization |
| **Apache Tika** | PDF document parsing for RAG ingestion |
| **Lombok** | Boilerplate reduction |

### Frontend
| Technology | Purpose |
|-----------|---------|
| **Flutter (Dart 3.0+)** | Cross-platform mobile framework |
| **Riverpod 2.6** | State management |
| **stomp_dart_client** | STOMP WebSocket client |
| **flutter_markdown** | Render AI markdown responses |
| **animated_text_kit** | Typewriter effects for AI responses |
| **Google Fonts** | Premium typography (Inter) |
| **Material 3** | Modern design system |

---

## 📁 Project Structure

```
EDUPay-1/
├── backend/                              # Spring Boot 3 Backend
│   ├── src/main/java/com/EduPay/
│   │   ├── config/
│   │   │   ├── AIConfig.java             # Spring AI ChatClient bean
│   │   │   ├── WebSocketConfig.java      # STOMP broker + /ws endpoint
│   │   │   ├── SecurityConfig.java       # JWT + role-based access
│   │   │   └── WebConfig.java            # CORS configuration
│   │   ├── controller/
│   │   │   ├── ChatController.java       # POST /api/ai/chat (RAG)
│   │   │   ├── NotificationController.java # Notification CRUD + admin trigger
│   │   │   ├── AdminController.java      # Student & fee management
│   │   │   └── StudentController.java    # Student-facing endpoints
│   │   ├── service/
│   │   │   ├── AIService.java            # RAG: vector search + Gemini + scoped context
│   │   │   ├── VectorIngestionService.java # PDF → chunks → pgvector embeddings
│   │   │   ├── NotificationService.java  # Scheduled AI reminders + WebSocket push
│   │   │   └── ...                       # Fee, Payment, Auth services
│   │   ├── model/
│   │   │   ├── Notification.java         # Notification entity
│   │   │   ├── Student.java, Fee.java    # Core JPA entities
│   │   │   └── User.java, Payment.java
│   │   └── repository/
│   │       ├── NotificationRepository.java
│   │       └── ...                       # JPA repositories
│   └── src/main/resources/
│       ├── application.yml               # Gemini API, pgvector, WebSocket config
│       └── data/school-handbook.pdf      # RAG knowledge source
│
├── frontend/edupay/                      # Flutter Frontend
│   └── lib/
│       ├── core/
│       │   └── constants/
│       │       └── app_theme.dart        # Premium dark theme + glassmorphism
│       ├── features/
│       │   ├── ai_chat/
│       │   │   ├── views/
│       │   │   │   └── chat_screen.dart  # Full AI chat with quick questions
│       │   │   └── widgets/
│       │   │       ├── message_bubble.dart # Animated bubbles + source tags
│       │   │       └── typing_indicator.dart # Three-dot bounce animation
│       │   └── dashboard/
│       │       └── widgets/
│       │           ├── fee_status_card.dart # Gradient card + progress bar
│       │           └── realtime_alert_list.dart # WebSocket notification stream
│       ├── models/
│       │   ├── ai_chat_response.dart     # AI response model
│       │   └── notification_message.dart # WebSocket message model
│       ├── services/
│       │   ├── ai_chat_service.dart      # REST client for AI chat
│       │   └── notification_service.dart # STOMP client + notification API
│       ├── screens/
│       │   ├── student/
│       │   │   └── student_dashboard.dart # AI FAB + notification bell
│       │   ├── admin/                    # Admin dashboard & management
│       │   └── auth/                     # JWT-based login
│       └── main.dart                     # App entry with Riverpod + dark theme
└── README.md                             # Project documentation
```

---

## 🛠️ Setup and Installation

### Prerequisites
- **Java 24+** (JDK)
- **Flutter SDK 3.0+**
- **PostgreSQL 12+** with `pgvector` extension
- **Maven 3.6+**
- **Google Cloud Project** with Vertex AI API enabled

### 1. Database Setup

```bash
# Create database
createdb edupay_db

# Enable pgvector extension
psql edupay_db -c "CREATE EXTENSION IF NOT EXISTS vector;"
```

### 2. Backend Setup

```bash
cd backend

# Configure in src/main/resources/application.yml:
# - spring.datasource.password: your PostgreSQL password
# - spring.ai.vertex.ai.gemini.project-id: your GCP project ID
# - jwt.secret: a strong random key (256+ bits)

# Build and run
./mvnw clean compile
./mvnw spring-boot:run
```
Backend runs on: `http://localhost:8080`

### 3. Frontend Setup

```bash
cd frontend/edupay

# Install dependencies
flutter pub get

# Configure API base URL in lib/constants/api_constants.dart

# Run the app
flutter run
```

---

## 🔐 Authentication & Security

- **JWT Authentication**: Stateless token-based auth for all API requests
- **Role-Based Access**: `ADMIN` and `STUDENT` roles with endpoint-level enforcement
- **Scoped AI Context**: AI only accesses fee data belonging to the logged-in user's student
- **WebSocket Auth**: JWT token passed in STOMP connect headers

---

## 📱 Key API Endpoints

### AI Chat
| Method | Endpoint | Description |
|--------|----------|-------------|
| `POST` | `/api/ai/chat` | Send question, get RAG-powered AI response with sources |

### Notifications
| Method | Endpoint | Description |
|--------|----------|-------------|
| `GET` | `/api/notifications` | Fetch user's notifications |
| `GET` | `/api/notifications/unread` | Get unread count |
| `PUT` | `/api/notifications/{id}/read` | Mark as read |
| `POST` | `/api/admin/notifications/trigger` | Admin: trigger AI fee reminders |

### Authentication
| Method | Endpoint | Description |
|--------|----------|-------------|
| `POST` | `/api/auth/register/admin` | Register admin |
| `POST` | `/api/auth/login` | Login (returns JWT) |

### Student & Fee Management
| Method | Endpoint | Description |
|--------|----------|-------------|
| `GET` | `/api/students` | List students |
| `POST` | `/api/students` | Add student |
| `GET` | `/api/fees/{studentId}` | Get student fees |
| `POST` | `/api/fees/{id}/payment` | Record payment |

### WebSocket
| Protocol | Endpoint | Description |
|----------|----------|-------------|
| `STOMP` | `/ws` | WebSocket handshake (SockJS) |
| Subscribe | `/topic/notifications/{userId}` | Real-time notification stream |

---

## 🧠 How the RAG Engine Works

```
1. INGESTION (On Startup)
   school-handbook.pdf → Tika Reader → Token Splitter → Embeddings → pgvector

2. QUERY (On User Question)
   "What is the late fee policy?"
         │
         ▼
   pgvector Similarity Search → Top 5 relevant chunks
         │
         ▼
   Build Augmented Prompt:
   ┌─────────────────────────────────────┐
   │ System: "You are EduPay AI..."      │
   │ Context: [Retrieved policy chunks]  │
   │ Student Data: [Scoped fee records]  │
   │ Question: "What is late fee policy?"│
   └─────────────────────────────────────┘
         │
         ▼
   Gemini 2.0 Flash → Grounded Answer + Source Citations
```

---

## 🎨 UI Features

- **AI Chat FAB**: Floating action button with gradient animation opens full-screen AI chat
- **Streaming Chat**: Messages with slide + fade entrance animations
- **Source Citations**: "📖 School Handbook, Page 12" tags below AI responses
- **Typing Indicator**: Three-dot bounce animation while AI generates
- **Notification Bell**: Badge count + pulse animation on new WebSocket messages
- **Fee Status Card**: Gradient card with progress bar and AI-generated insights
- **Real-Time Alert List**: AnimatedList with WebSocket stream subscription
- **Dark Glassmorphism Theme**: Premium dark UI with gradient accents

---

## 🌐 Deployment

### Backend (Railway / Render)
1. Push code to GitHub
2. Connect repo to Railway/Render
3. Set environment variables:
   - `SPRING_DATASOURCE_URL`, `SPRING_DATASOURCE_USERNAME`, `SPRING_DATASOURCE_PASSWORD`
   - `GOOGLE_CLOUD_PROJECT_ID`, `GOOGLE_CLOUD_LOCATION`
   - `JWT_SECRET`

### Frontend (App Stores)
```bash
flutter build apk      # Android
flutter build ios       # iOS
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
  <strong>Built with ❤️ using Spring AI, Gemini, pgvector & Flutter</strong>
</p>

# EduPay: School Fees & Announcement Management App

## 📚 Overview

EduPay is a comprehensive mobile application designed to streamline student fee management, announcements, and online payments for schools. It features a multi-role architecture with secure authentication, allowing administrators to manage students and payments while students can view their fees and payment history.

## ✨ Features

- **Multi-Admin Support**: Administrators can manage their own students and fee records
- **JWT Authentication**: Secure role-based access control for Admins and Students
- **Student Management**: Create, update, and delete student records with fee information
- **Fee Tracking**: Manage student fee statuses (paid/unpaid, partially paid) and record cash/online payments
- **Announcements**: Admins can post announcements; both admins and students can view them
- **Online Payments**: Razorpay integration ready for secure online fee payments
- **Payment History & Receipts**: View payment history and auto-generated receipts for all transactions
- **Local Storage**: JWT tokens stored securely using shared_preferences
- **Cloud Deployment Ready**: Designed for Railway.app or Render.com with PostgreSQL

## 🚀 Tech Stack

### Frontend (Flutter)
- **Framework**: Flutter (Dart 3.0+)
- **HTTP Client**: `http` package for API communication
- **Local Storage**: `shared_preferences` for token management
- **Date Handling**: `intl` for date formatting
- **UI Design**: Material 3 design system

### Backend (Spring Boot)
- **Framework**: Spring Boot 3.5.4 (Java 24)
- **Database**: PostgreSQL with Spring Data JPA
- **Security**: Spring Security with JWT authentication
- **Build Tool**: Maven
- **Utilities**: Lombok for boilerplate reduction

## 📁 Project Structure

```
EDUPay-1/
├── backend/                    # Spring Boot backend
│   ├── src/main/java/com/EduPay/
│   │   ├── controller/        # REST API endpoints
│   │   ├── service/           # Business logic
│   │   ├── repository/        # JPA data access
│   │   ├── model/             # JPA entities
│   │   ├── dto/               # Data transfer objects
│   │   ├── config/            # Security & CORS configuration
│   │   ├── util/              # Utility classes
│   │   ├── exception/         # Exception handling
│   │   └── Application.java   # Spring Boot entry point
│   ├── src/main/resources/
│   │   └── application.properties  # Configuration
│   └── pom.xml               # Maven dependencies
│
└── frontend/edupay/           # Flutter frontend
    ├── lib/
    │   ├── main.dart         # App entry point
    │   ├── constants/        # API & app constants
    │   ├── models/           # Data models/DTOs
    │   ├── services/         # API client services
    │   ├── screens/
    │   │   ├── auth/         # Login & authentication screens
    │   │   ├── admin/        # Admin dashboard & management screens
    │   │   ├── student/      # Student fee & payment screens
    │   │   └── common/       # Shared screens (announcements, etc.)
    │   └── utils/            # Helper functions & token management
    ├── android/              # Android native configuration
    ├── ios/                  # iOS native configuration
    ├── web/                  # Web version configuration
    ├── pubspec.yaml          # Flutter dependencies
    └── analysis_options.yaml # Dart linting rules
```

## 🛠️ Setup and Installation

### Prerequisites
- Java 24+
- Flutter SDK 3.0+
- PostgreSQL 12+
- Maven 3.6+

### 1. Backend Setup

1. **Database Setup (PostgreSQL)**:
   ```bash
   # Create database
   createdb edupay_db
   ```

2. **Configure Database Connection**:
   - Open `backend/src/main/resources/application.properties`
   - Update credentials:
   ```properties
   spring.datasource.url=jdbc:postgresql://localhost:5432/edupay_db
   spring.datasource.username=postgres
   spring.datasource.password=your_password
   ```

3. **Set JWT Secret Key**:
   - Add a strong random key in `application.properties`:
   ```properties
   jwt.secret=your_secure_256bit_random_key_here
   ```

4. **Build and Run**:
   ```bash
   cd backend
   mvn clean install
   mvn spring-boot:run
   ```
   - Backend runs on: `http://localhost:8080`

### 2. Frontend Setup

1. **Install Dependencies**:
   ```bash
   cd frontend/edupay
   flutter pub get
   ```

2. **Configure API Base URL**:
   - Open `lib/constants/api_constants.dart`
   - Update `BASE_URL` based on your environment:
   
   **Android Emulator**:
   ```dart
   static const String BASE_URL = 'http://10.0.2.2:8080/api';
   ```
   
   **iOS Simulator/Localhost**:
   ```dart
   static const String BASE_URL = 'http://localhost:8080/api';
   ```
   
   **Physical Device** (replace with your machine IP):
   ```dart
   static const String BASE_URL = 'http://YOUR_MACHINE_IP:8080/api';
   ```
   
   **Deployed Backend**:
   ```dart
   static const String BASE_URL = 'https://your-backend-domain.com/api';
   ```

3. **Run the App**:
   ```bash
   flutter run
   ```

## 🚀 Running the Application

1. **Start Backend**: 
   - Ensure PostgreSQL is running
   - Navigate to backend folder and run `mvn spring-boot:run`
   - Verify it's running on `http://localhost:8080`

2. **Start Frontend**:
   - Open Flutter project
   - Connect a device or start an emulator
   - Run `flutter run`

3. **Login Credentials**:
   - **Admin**: Credentials set during admin registration
   - **Student**: Credentials assigned by admin

## 🔐 Authentication Flow

- Users login with email and password
- Backend returns JWT token (stored in `shared_preferences`)
- Token is used for authenticated API requests
- Separate access paths for Admin and Student roles

## 📱 Key API Endpoints

### Authentication
- `POST /api/auth/register/admin` - Register new admin
- `POST /api/auth/login` - Login (returns JWT token)

### Student Management (Admin)
- `GET /api/students` - List all students
- `POST /api/students` - Add new student
- `PUT /api/students/{id}` - Update student
- `DELETE /api/students/{id}` - Delete student

### Fee Management
- `GET /api/fees/{studentId}` - Get student fees
- `PUT /api/fees/{id}/status` - Update fee status
- `POST /api/fees/{id}/payment` - Record payment

### Announcements
- `GET /api/announcements` - List announcements
- `POST /api/announcements` - Create announcement (Admin)

## 📦 Dependencies

### Backend
- Spring Boot Web, Data JPA, Security
- PostgreSQL JDBC Driver
- Lombok
- JWT (io.jsonwebtoken)

### Frontend
- http (API calls)
- shared_preferences (local storage)
- intl (date formatting)
- cupertino_icons (icons)

## 🌐 Deployment

### Backend Deployment (Railway.app / Render.com)
- Push code to GitHub
- Connect repository to Railway/Render
- Set environment variables:
  - Database URL
  - JWT Secret
  - Port (usually 8080)

### Frontend Deployment (App Stores)
- Build APK for Android: `flutter build apk`
- Build IPA for iOS: `flutter build ios`
- Upload to respective app stores

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit changes (`git commit -m 'Add AmazingFeature'`)
4. Push to branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 👨‍💻 Author

**Naman Jain**
- Email: [nj260106@gmail.com](mailto:nj260106@gmail.com)
- GitHub: [@engnaman7752](https://github.com/engnaman7752)

Developed as a comprehensive school management solution.

## 📞 Support

For issues and questions, please:
- Create an issue in the repository
- Email: nj260106@gmail.com
- Contact via GitHub: [@engnaman7752](https://github.com/engnaman7752)

---

**Note**: This is a development version. For production use, ensure all security measures are properly configured, including strong JWT secrets, CORS policies, and database encryption.

Add Student (as Admin): POST /api/admin/students (use admin JWT)

Login Student: POST /api/auth/login (use student name/mobile, get JWT token)

Access Student Data (as Student): GET /api/student/fees, GET /api/student/payments/history (use student JWT)

Record Cash Payment (as Admin): POST /api/admin/fees/cash-deposit (use admin JWT)



Feel free to explore and enhance the application!

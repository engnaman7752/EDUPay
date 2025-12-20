EduPay: School Fees & Announcement Management App
📚 Overview
EduPay is a comprehensive mobile application designed to streamline student fee management, announcements, and online payments for schools. It features a multi-tenant architecture, allowing multiple administrators to manage their own students and data securely.

✨ Features
Multi-Admin Support: Each admin manages their own set of students and data.

JWT Authentication: Secure role-based access for Admins and Students.

Student Management: Admins can add, update, and delete student records.

Fee Tracking: Admins can manage student fee statuses (paid/unpaid, partially paid) and record cash deposits.

Announcements: Admins can post announcements, and both admins and students can view them.

Online Payments: Students can view their fee status and pay online (Razorpay integration ready).

Payment History & Receipts: Students can view their payment history and auto-generated receipts for both online and cash payments.

Cloud Deployment Ready: Designed for deployment on platforms like Railway.app or Render.com with PostgreSQL.

🚀 Technologies Used
Frontend (Flutter)
Framework: Flutter (Dart)

State Management: (Can be added later, e.g., Provider, Riverpod)

HTTP Client: http package

Local Storage: shared_preferences

Date Formatting: intl

Backend (Spring Boot)
Framework: Spring Boot (Java)

Database: PostgreSQL

ORM: Spring Data JPA / Hibernate

Security: Spring Security (JWT for authentication)

Payment Gateway: Razorpay (integration logic in backend)

Build Tool: Maven

Utilities: Lombok, JJWT

🏗️ Project Structure
Backend (com.edupay/)
com.edupay/
├── controller/       # REST APIs
├── service/          # Business logic
├── repository/       # JPA DB access
├── entity/           # DB tables (User, Student, Fee, etc.)
├── dto/              # Login & response formats
├── config/           # Security (JWT, CORS)
├── util/             # Helpers (JWT, date)
└── exception/        # Error handling

Frontend (edupay_app/lib/)
edupay_app/lib/
├── main.dart
├── constants/        # API base URL
├── models/           # Dart DTOs/models
├── services/         # API service classes
├── screens/          # UI pages (auth, admin, student, common)
└── utils/            # Token management, helpers

🛠️ Setup and Installation
1. Backend Setup
Clone the repository: (Assuming you have your backend code in a directory, e.g., EduPay/)

Database Setup (PostgreSQL):

Ensure PostgreSQL is installed and running on your local machine.

Create a new database, e.g., edupay_db.

Update src/main/resources/application.properties with your database credentials:

spring.datasource.url=jdbc:postgresql://localhost:5432/edupay_db
spring.datasource.username=postgres
spring.datasource.password=7752

JWT Secret Key: In application.properties, replace the placeholder for jwt.secret with a strong, random key.

jwt.secret=yourSuperSecretKeyThatIsAtLeast256BitsLongAndRandomlyGeneratedForEduPayApp

Build and Run Backend:

Navigate to the backend project root (EduPay/).

Run mvn clean install to build the project and download dependencies.

Run the Spring Boot application: mvn spring-boot:run or run from your IDE.

The backend will start on http://localhost:8080.

2. Frontend Setup
Navigate to Flutter project:

cd edupay_app

Install dependencies:

flutter pub get

Configure API Base URL:

Open lib/constants/api_constants.dart.

Set the BASE_URL to your backend's address.

For Android Emulator: static const String BASE_URL = 'http://10.0.2.2:8080/api';

For iOS Simulator/Localhost: static const String BASE_URL = 'http://localhost:8080/api';

For physical device (if backend is on your machine): static const String BASE_URL = 'http://YOUR_MACHINE_IP:8080/api';

For deployed backend: static const String BASE_URL = 'https://your-backend-domain.com/api';

🚀 How to Run the App
Ensure your Spring Boot backend is running.

Open your Flutter project in your IDE (VS Code or Android Studio).

Select a device (emulator or physical device).

Run the app:

flutter run

🧪 Testing with Postman
To test the backend API endpoints, refer to the detailed Postman Testing Guide provided previously. The general flow is:

Register Admin: POST /api/auth/register/admin

Login Admin: POST /api/auth/login (get JWT token)

Add Student (as Admin): POST /api/admin/students (use admin JWT)

Login Student: POST /api/auth/login (use student name/mobile, get JWT token)

Access Student Data (as Student): GET /api/student/fees, GET /api/student/payments/history (use student JWT)

Record Cash Payment (as Admin): POST /api/admin/fees/cash-deposit (use admin JWT)



Feel free to explore and enhance the application!
email nj260106@gmail.com

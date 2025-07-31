EduPay: School Fees & Announcement Management App
A comprehensive mobile application designed to streamline student fee management, announcements, and online payments for schools.

🌟 About
EduPay is a full-stack project built with Flutter and Spring Boot, designed to showcase a multi-tenant application with role-based access control. The app allows school administrators to manage student data and finances, while students can track their fees and make online payments.

Author: Naman Jain

GitHub: engnaman7752

Email: namanjain1237752@gmail.com

✨ Features
Multi-Admin Support: Each admin manages their own set of students and data.

JWT Authentication: Secure role-based access for Admins and Students.

Student Management: Admins can add, update, and delete student records.

Fee Tracking: Admins can manage student fee statuses (paid/unpaid, partially paid) and record cash deposits.

Announcements: Admins can post announcements, and both admins and students can view them.

Online Payments: Students can view their fee status and pay online (Razorpay integration ready).

Payment History & Receipts: Students can view their payment history and auto-generated receipts for both online and cash payments.

🚀 Technologies Used
Frontend (Flutter)
Framework: Flutter (Dart)

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
The project follows a modular, layered architecture for both the frontend and backend.

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
Clone the repository:

git clone https://github.com/engnaman7752/EduPay.git
cd EduPay

Database Setup (PostgreSQL):

Ensure PostgreSQL is installed and running.

Create a database named edupay_db.

Update src/main/resources/application.properties with your credentials:

spring.datasource.url=jdbc:postgresql://localhost:5432/edupay_db
spring.datasource.username=postgres
spring.datasource.password=7752

JWT Secret Key: In application.properties, set jwt.secret to a strong, random key.

Build and Run Backend:

Run mvn clean install to build.

Run the Spring Boot application: mvn spring-boot:run or from your IDE.

2. Frontend Setup
Navigate to Flutter project:

cd edupay_app

Install dependencies:

flutter pub get

Configure API Base URL:

Open lib/constants/api_constants.dart.

The project uses conditional logic to determine the BASE_URL based on the platform. However, for physical Android devices, you must manually set your host machine's IP address.

Example for physical device: return 'http://192.168.1.5:8080/api';

Run the App:

flutter run

🧪 Testing with Postman
A Postman collection is recommended for testing all API endpoints. The general flow is:

Register Admin: POST /api/auth/register/admin

Login Admin: POST /api/auth/login (get JWT token)

Add Student (as Admin): POST /api/admin/students (use admin JWT)

Login Student: POST /api/auth/login (use student name/mobile, get JWT token)

Access Student Data (as Student): GET /api/student/fees (use student JWT)

Record Cash Payment (as Admin): POST /api/admin/fees/cash-deposit (use admin JWT)

🤝 Contribution
Contributions are welcome! If you find a bug or have a suggestion, please open an issue or submit a pull request.

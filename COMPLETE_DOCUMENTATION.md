# Production-Ready Authentication App
## Full Stack: Flutter + Express.js + MySQL

Complete MVP authentication system with JWT, refresh tokens, and secure storage.

---

## 📋 Table of Contents

1. [Quick Start](#quick-start)
2. [JWT Authentication Flow](#jwt-authentication-flow)
3. [Security Features](#security-features)
4. [Project Structure](#project-structure)
5. [Setup Instructions](#setup-instructions)
6. [API Documentation](#api-documentation)
7. [Testing Checklist](#testing-checklist)
8. [Deployment Guide](#deployment-guide)

---

## 🚀 Quick Start

### Prerequisites
- Node.js 14+
- MySQL 5.7+
- Flutter 3.x+
- Dart 3.x+

### Backend
```bash
cd backend
npm install
cp .env.example .env
# Edit .env with your database credentials
npm run dev
```

### Frontend
```bash
cd frontend
flutter pub get
flutter run
```

### Database
```bash
mysql -u root -p < ../database_schema.sql
```

---

## 🔐 JWT Authentication Flow Explanation

### How the Secure JWT Flow Works

#### **1. User Registration**
```
User Input → Flutter UI
    ↓
Validation (email, password length, etc.)
    ↓
POST /api/auth/register
    ↓
Backend: Hash password with bcryptjs
    ↓
Database: Insert user with hashed password
    ↓
Response: Success message
    ↓
Redirect to Login
```

#### **2. User Login**
```
User Input (email, password) → Flutter UI
    ↓
POST /api/auth/login
    ↓
Backend: Find user by email
    ↓
Backend: Compare password with bcrypt
    ↓
IF password matches:
    ├─ Generate Access Token (15 min expiry)
    ├─ Generate Refresh Token (7 days expiry)
    ├─ Store Refresh Token in database
    └─ Return both tokens
    ↓
Flutter: Store tokens securely
    ├─ Access Token → RAM + secure storage
    ├─ Refresh Token → Secure storage only
    └─ User info → Secure storage
    ↓
Redirect to Home
```

#### **3. Making Protected API Calls**
```
User: GET /api/user/profile
    ↓
Flutter: Attach Access Token to headers
    ├─ Authorization: Bearer {access_token}
    ↓
Backend: Verify JWT signature
    ├─ Check token expiry
    ├─ Extract user ID from payload
    ↓
IF valid:
    ├─ Fetch user data
    └─ Return profile
ELSE IF expired:
    └─ Return 401 Unauthorized
```

#### **4. Token Refresh (Automatic)**
```
Backend returns 401 (expired token)
    ↓
Flutter: Detect 401 error
    ↓
Flutter: Extract Refresh Token from storage
    ↓
POST /api/auth/refresh-token
    {
        "refreshToken": "token_here"
    }
    ↓
Backend: Verify Refresh Token
    ├─ Check in database
    ├─ Verify JWT signature
    ├─ Check expiry
    ↓
IF valid:
    ├─ Generate new Access Token
    ├─ Return new token
    ↓
Flutter: Update stored Access Token
    ↓
Retry original request with new token
ELSE:
    └─ Force logout
```

#### **5. User Logout**
```
User clicks Logout → Flutter UI
    ↓
POST /api/auth/logout
    {
        "refreshToken": "token_here"
    }
    ↓
Backend: Delete Refresh Token from database
    ↓
Flutter: Clear all stored tokens
    ├─ Delete Access Token
    ├─ Delete Refresh Token
    ├─ Delete User Info
    ↓
Redirect to Login
```

### Token Structure

**Access Token (JWT payload):**
```json
{
  "userId": 1,
  "email": "user@example.com",
  "iat": 1234567890,
  "exp": 1234568890
}
```

**Refresh Token (JWT payload):**
```json
{
  "userId": 1,
  "iat": 1234567890,
  "exp": 1641234567890
}
```

### Why This Design is Secure

1. **Short-lived Access Tokens (15 min)**
   - Even if stolen, usable only briefly
   - Reduces damage window

2. **Long-lived Refresh Tokens (7 days)**
   - Stored securely in device storage
   - Never transmitted over unsecured channels
   - Database validation adds extra layer

3. **bcryptjs Password Hashing**
   - Passwords never stored in plain text
   - Impossible to reverse
   - Slow algorithm prevents brute force

4. **Flutter Secure Storage**
   - Android: Keystore encryption
   - iOS: Keychain encryption
   - Platform-native security

5. **Token Validation**
   - JWT signature verification
   - Expiry checking
   - Database record validation

6. **CORS Protection**
   - Only your domain can access backend
   - Prevents unauthorized cross-origin requests

---

## 🛡️ Security Features

✅ **Bcryptjs Password Hashing**
- Prevents rainbow table attacks
- Salt rounds: 10 (production-grade)

✅ **JWT Tokens**
- Stateless authentication
- Tamper-proof (signed)
- Time-limited access

✅ **Refresh Token Rotation**
- Database tracking
- Revocation possible
- Automatic cleanup of expired tokens

✅ **Secure Storage**
- Flutter: Native platform encryption
- Backend: Environment variables
- Never hardcode secrets

✅ **CORS & Origin Control**
- Backend configured for specific origins
- Prevents unauthorized access

✅ **Input Validation**
- Email format checking
- Password strength validation
- SQL injection prevention (via mysql2)

✅ **Error Handling**
- Generic error messages (no info leakage)
- Proper HTTP status codes
- Development vs production logging

---

## 📁 Project Structure

### Backend
```
backend/
├── config/
│   └── database.js              # MySQL connection pool
├── controllers/
│   └── authController.js        # HTTP request handlers
├── middleware/
│   └── authMiddleware.js        # JWT verification & error handling
├── routes/
│   └── authRoutes.js            # Route definitions
├── services/
│   └── authService.js           # Business logic
├── .env.example                 # Environment template
├── .gitignore
├── app.js                       # Express app
├── server.js                    # Entry point
├── package.json
└── README.md
```

### Frontend
```
frontend/lib/
├── core/
│   ├── constants.dart           # API config & constants
│   └── services/
│       ├── api_service.dart     # Dio HTTP client
│       └── secure_storage_service.dart
├── models/
│   └── user_model.dart          # User data model
├── features/
│   └── auth/
│       ├── screens/
│       │   ├── splash_screen.dart
│       │   ├── login_screen.dart
│       │   ├── register_screen.dart
│       │   ├── home_screen.dart
│       │   └── profile_screen.dart
│       ├── widgets/
│       │   └── auth_widgets.dart    # Reusable components
│       ├── controller/
│       │   └── auth_controller.dart # Riverpod state management
│       └── repository/
│           └── auth_repository.dart # Data access layer
├── routes/
│   └── app_router.dart          # GoRouter navigation
└── main.dart                    # App entry point
```

### Database
```
MySQL Schema:
├── users table
│   ├── id (PK)
│   ├── name
│   ├── email (UNIQUE)
│   ├── password_hash
│   ├── created_at
│   └── updated_at
└── refresh_tokens table
    ├── id (PK)
    ├── user_id (FK → users.id)
    ├── token (LONGTEXT)
    ├── expires_at
    └── created_at
```

---

## 🔧 Setup Instructions

### Step 1: Database Setup

```bash
# Connect to MySQL
mysql -u root -p

# Run schema
source database_schema.sql

# Verify tables
USE auth_app_db;
SHOW TABLES;
```

### Step 2: Backend Setup

```bash
cd backend

# Install dependencies
npm install

# Create .env file
cp .env.example .env

# Edit .env with your values
nano .env
```

### .env Configuration
```env
PORT=5000
NODE_ENV=development

DB_HOST=localhost
DB_PORT=3306
DB_USER=root
DB_PASSWORD=your_password
DB_NAME=auth_app_db

JWT_ACCESS_SECRET=change_me_in_production_123
JWT_REFRESH_SECRET=change_me_in_production_456
JWT_ACCESS_EXPIRY=15m
JWT_REFRESH_EXPIRY=7d

CORS_ORIGIN=http://192.168.1.100:3000
```

### Step 3: Start Backend

```bash
# Development (with auto-reload)
npm run dev

# Output:
# ╔════════════════════════════════════════╗
# ║   Authentication Server Started        ║
# ║   Port: 5000                           ║
# ║   Environment: development             ║
# ╚════════════════════════════════════════╝
```

### Step 4: Flutter Setup

```bash
cd frontend

# Get dependencies
flutter pub get

# Update API URL in lib/core/constants.dart
# Change baseUrl to your backend IP
# Example: http://192.168.1.100:5000/api

# Run app
flutter run
```

---

## 📡 API Documentation

### Base URL
```
http://localhost:5000/api
```

### 1. Register User
```http
POST /auth/register
Content-Type: application/json

{
  "name": "John Doe",
  "email": "john@example.com",
  "password": "password123",
  "confirmPassword": "password123"
}
```

**Success Response (201):**
```json
{
  "success": true,
  "message": "User registered successfully"
}
```

**Error Response (409):**
```json
{
  "success": false,
  "message": "Email already registered"
}
```

---

### 2. Login User
```http
POST /auth/login
Content-Type: application/json

{
  "email": "john@example.com",
  "password": "password123"
}
```

**Success Response (200):**
```json
{
  "success": true,
  "message": "Login successful",
  "data": {
    "userId": 1,
    "name": "John Doe",
    "email": "john@example.com",
    "accessToken": "eyJhbGc...",
    "refreshToken": "eyJhbGc..."
  }
}
```

---

### 3. Get User Profile
```http
GET /user/profile
Authorization: Bearer {accessToken}
```

**Success Response (200):**
```json
{
  "success": true,
  "message": "Profile fetched successfully",
  "data": {
    "id": 1,
    "name": "John Doe",
    "email": "john@example.com",
    "created_at": "2024-01-15T10:30:00Z",
    "updated_at": "2024-01-15T10:30:00Z"
  }
}
```

---

### 4. Refresh Access Token
```http
POST /auth/refresh-token
Content-Type: application/json

{
  "refreshToken": "eyJhbGc..."
}
```

**Success Response (200):**
```json
{
  "success": true,
  "message": "Access token refreshed",
  "data": {
    "accessToken": "eyJhbGc..."
  }
}
```

---

### 5. Logout User
```http
POST /auth/logout
Content-Type: application/json

{
  "refreshToken": "eyJhbGc..."
}
```

**Success Response (200):**
```json
{
  "success": true,
  "message": "Logout successful"
}
```

---

## ✅ Testing Checklist

### 1. Backend Testing

- [ ] **Database Connection**
  - [ ] MySQL running and accessible
  - [ ] Database `auth_app_db` created
  - [ ] Tables `users` and `refresh_tokens` exist

- [ ] **Registration Endpoint**
  - [ ] Valid registration creates user
  - [ ] Duplicate email rejected (409)
  - [ ] Invalid email format rejected (400)
  - [ ] Password too short rejected (400)
  - [ ] Passwords don't match rejected (400)
  - [ ] Password hashed in database (never plain text)

- [ ] **Login Endpoint**
  - [ ] Correct credentials return tokens (200)
  - [ ] Wrong password rejected (401)
  - [ ] Non-existent email rejected (401)
  - [ ] Both access and refresh tokens returned
  - [ ] Refresh token saved in database

- [ ] **Profile Endpoint**
  - [ ] Valid token returns profile (200)
  - [ ] Missing token rejected (401)
  - [ ] Invalid token rejected (401)
  - [ ] Expired token rejected (401)

- [ ] **Refresh Token Endpoint**
  - [ ] Valid refresh token returns new access token (200)
  - [ ] Invalid refresh token rejected (401)
  - [ ] Expired refresh token rejected (401)
  - [ ] New access token works for protected routes

- [ ] **Logout Endpoint**
  - [ ] Valid refresh token accepted
  - [ ] Token removed from database
  - [ ] Old tokens don't work after logout

### 2. Frontend Testing

- [ ] **Splash Screen**
  - [ ] Shows on app launch
  - [ ] Checks authentication status
  - [ ] Redirects to login if not authenticated
  - [ ] Redirects to home if authenticated

- [ ] **Registration Screen**
  - [ ] All fields validate correctly
  - [ ] Form submission works
  - [ ] Success dialog shows and redirects to login
  - [ ] Error dialog shows for duplicate email
  - [ ] Navigation link to login works

- [ ] **Login Screen**
  - [ ] All fields validate correctly
  - [ ] Success redirects to home
  - [ ] Error shows for invalid credentials
  - [ ] Tokens stored securely
  - [ ] Navigation link to register works

- [ ] **Home Screen**
  - [ ] Displays user name from state
  - [ ] View Profile button navigates to profile
  - [ ] Logout button clears tokens and redirects to login

- [ ] **Profile Screen**
  - [ ] Fetches and displays user data
  - [ ] Shows user info correctly
  - [ ] Logout button works
  - [ ] Back button navigates to home

- [ ] **Auto-Login**
  - [ ] Tokens persist after app restart
  - [ ] User stays logged in on app reopen
  - [ ] Expired tokens trigger re-login

### 3. Security Testing

- [ ] **Token Security**
  - [ ] Access tokens expire after 15 minutes
  - [ ] Refresh tokens expire after 7 days
  - [ ] Tokens stored in secure storage (not in plain text)
  - [ ] Tokens only accessible to the app

- [ ] **Password Security**
  - [ ] Passwords hashed with bcrypt
  - [ ] Password never logged or displayed
  - [ ] Same password hashes differently (salt)

- [ ] **API Security**
  - [ ] Protected routes require valid token
  - [ ] CORS allows only configured origins
  - [ ] Error messages don't leak sensitive info

### 4. Error Handling

- [ ] **Network Errors**
  - [ ] Connection timeout shows error message
  - [ ] No internet shows appropriate error
  - [ ] Retry functionality works

- [ ] **API Errors**
  - [ ] 400 errors show validation messages
  - [ ] 401 errors trigger logout
  - [ ] 500 errors show generic message

### 5. User Flow Testing

**Flow 1: New User**
```
1. Launch app → Splash Screen → Login Screen
2. Click "Sign Up"
3. Register Screen → Fill form → Submit
4. Success → Login Screen
5. Login → Home Screen → ✓ Success
```

**Flow 2: Existing User**
```
1. Login → Home Screen
2. Home Screen → View Profile → Profile Screen
3. Profile Screen → Logout → Confirmation Dialog
4. Logout → Login Screen → ✓ Success
```

**Flow 3: Session Persistence**
```
1. Login → Home Screen
2. Kill app
3. Relaunch app → Splash Screen → Home Screen (auto-login)
4. ✓ Token still valid
```

**Flow 4: Token Refresh**
```
1. Login → Get access token (exp: 15 min)
2. Wait for token to expire (in dev, modify expiry to test)
3. Make API call
4. Automatic token refresh happens
5. API call succeeds with new token
6. ✓ Seamless for user
```

### 6. Performance Testing

- [ ] **Load Time**
  - [ ] Splash screen appears within 2 seconds
  - [ ] API calls respond within 3 seconds
  - [ ] Profile loads quickly (< 1 second)

- [ ] **Memory Usage**
  - [ ] App doesn't crash on normal usage
  - [ ] No memory leaks on multiple login/logout cycles
  - [ ] Smooth animations throughout

### 7. Play Store Compliance

- [ ] **Permissions**
  - [ ] Only request necessary permissions
  - [ ] Handle permission denials gracefully

- [ ] **Privacy**
  - [ ] Clear privacy policy in place
  - [ ] No unauthorized data collection
  - [ ] Tokens only used for authentication

- [ ] **UI/UX**
  - [ ] No crashes or force closes
  - [ ] Proper back button handling
  - [ ] Loading states for all async operations

---

## 🚀 Deployment Guide

### Backend Deployment (Production)

#### 1. Environment Variables
```env
NODE_ENV=production
PORT=5000

# Database (Use managed service in production)
DB_HOST=your-db-host.com
DB_USER=prod_user
DB_PASSWORD=strong_password_here
DB_NAME=auth_app_db

# JWT (Use strong secrets)
JWT_ACCESS_SECRET=generate_strong_random_key_here
JWT_REFRESH_SECRET=generate_another_strong_key_here
JWT_ACCESS_EXPIRY=15m
JWT_REFRESH_EXPIRY=7d

# CORS (Your production domain)
CORS_ORIGIN=https://yourapp.com
```

#### 2. Deploy to Heroku/Railway/Render

```bash
# Using Heroku as example
heroku create your-auth-app
heroku config:set NODE_ENV=production
heroku config:set DB_HOST=your-db-host.com
# ... set all env variables
git push heroku main
```

#### 3. Database Backup
```bash
# Regular backups
mysqldump -u prod_user -p auth_app_db > backup.sql
```

### Frontend Deployment (Play Store/App Store)

#### 1. Build Release APK (Android)
```bash
flutter build apk --release
# Output: build/app/release/app-release.apk
```

#### 2. Update API URL
```dart
// lib/core/constants.dart
static const String baseUrl = 'https://your-api-domain.com/api';
```

#### 3. Sign APK
```bash
jarsigner -verbose -sigalg SHA1withRSA -digestalg SHA1 \
  -keystore ~/key.jks build/app/release/app-release.apk alias_name
```

#### 4. Submit to Play Store/App Store

---

## 📝 Notes

- **Data Privacy**: Implement privacy policy per App Store requirements
- **Password Reset**: Not included in MVP; add via email service
- **Rate Limiting**: Add to prevent brute force attacks
- **Logging**: Enable structured logging in production
- **Monitoring**: Set up error tracking (Sentry, etc.)
- **Database**: Use cloud-managed databases (AWS RDS, Digital Ocean, etc.)
- **API**: Consider API versioning for future updates

---

## 📚 Resources

- [JWT Best Practices](https://tools.ietf.org/html/rfc7519)
- [OWASP Authentication Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Authentication_Cheat_Sheet.html)
- [Flutter Security Best Practices](https://flutter.dev/docs/development/best-practices/security)

---

**Version**: 1.0.0  
**Last Updated**: 2024  
**Status**: Production Ready

# 🚀 Quick Start Guide

Get the authentication app running in 10 minutes!

## Prerequisites
- Node.js 14+ installed
- MySQL 5.7+ running locally
- Flutter 3.x+ installed
- Android Emulator or iOS Simulator (or physical device)

---

## Step 1: Database Setup (2 minutes)

### Option A: Using MySQL Command Line
```bash
# Connect to MySQL
mysql -u root -p

# Run the schema file
source database_schema.sql

# Verify
USE auth_app_db;
SHOW TABLES;
```

### Option B: Using MySQL Workbench
1. Open MySQL Workbench
2. File → Open SQL Script
3. Select `database_schema.sql`
4. Execute

**Expected Output:**
```
mysql> SHOW TABLES;
+---------------------+
| Tables_in_auth_app  |
+---------------------+
| refresh_tokens      |
| users               |
+---------------------+
```

---

## Step 2: Backend Setup (3 minutes)

```bash
# Navigate to backend
cd backend

# Install dependencies
npm install

# Create environment file
cp .env.example .env

# Edit .env with your database credentials
# On Windows:
notepad .env

# On macOS/Linux:
nano .env
```

**Edit these values in .env:**
```env
DB_USER=root
DB_PASSWORD=your_mysql_password
DB_NAME=auth_app_db
```

### Start Backend
```bash
npm run dev
```

**Expected Output:**
```
╔════════════════════════════════════════╗
║   Authentication Server Started        ║
║   Port: 5000                           ║
║   Environment: development             ║
╚════════════════════════════════════════╝
```

✅ **Backend is now running on `http://localhost:5000`**

---

## Step 3: Test Backend (2 minutes)

### Using curl or Postman

**Test 1: Health Check**
```bash
curl http://localhost:5000/api/health
```

Expected Response:
```json
{
  "success": true,
  "message": "Server is running"
}
```

**Test 2: Register User**
```bash
curl -X POST http://localhost:5000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "name": "John Doe",
    "email": "john@example.com",
    "password": "password123",
    "confirmPassword": "password123"
  }'
```

Expected Response:
```json
{
  "success": true,
  "message": "User registered successfully"
}
```

**Test 3: Login**
```bash
curl -X POST http://localhost:5000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "john@example.com",
    "password": "password123"
  }'
```

Expected Response:
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

## Step 4: Flutter Setup (2 minutes)

### In a new terminal:
```bash
cd frontend

# Get dependencies
flutter pub get

# Update API URL (if using physical device or remote)
# Edit: lib/core/constants.dart
```

### If using local backend:
Change `ApiConfig.baseUrl` in `lib/core/constants.dart`:
```dart
// For Android Emulator:
static const String baseUrl = 'http://10.0.2.2:5000/api';

// For iOS Simulator:
static const String baseUrl = 'http://localhost:5000/api';

// For physical device (replace with your machine IP):
static const String baseUrl = 'http://192.168.1.100:5000/api';
```

### Start Flutter App
```bash
# Run on emulator/simulator
flutter run

# Or on physical device
flutter run -d device_id

# Release mode
flutter run --release
```

---

## Step 5: Test the App (1 minute)

1. **Splash Screen** - Loading screen appears
2. **Login Screen** - Click "Sign Up"
3. **Register Screen** - Fill form:
   - Name: `John Doe`
   - Email: `john@test.com`
   - Password: `password123`
   - Confirm: `password123`
4. **Success** - Dialog appears, redirects to login
5. **Login** - Enter credentials and login
6. **Home Screen** - Welcome message displays
7. **View Profile** - Click button to see profile details
8. **Logout** - Click logout, confirms, and returns to login

✅ **Everything working!**

---

## 🔧 Troubleshooting

### Backend Issues

**"Cannot connect to database"**
```bash
# Check if MySQL is running
# Windows: Services app → MySQL
# macOS: brew services list
# Linux: sudo systemctl status mysql

# Verify credentials in .env
# Make sure auth_app_db exists
mysql -u root -p -e "SHOW DATABASES;"
```

**"Port 5000 already in use"**
```bash
# Change port in .env
PORT=3001

# Or kill the process using port 5000
# Windows: netstat -ano | findstr :5000
# macOS/Linux: lsof -i :5000 | kill -9
```

### Flutter Issues

**"Connection refused"**
- Make sure backend is running
- Check API URL in `constants.dart`
- If on physical device, verify IP address

**"Build failed"**
```bash
# Clean Flutter build
flutter clean

# Get dependencies again
flutter pub get

# Run again
flutter run
```

**"Platform exception"**
- For Android: Check `compileSdkVersion` in `android/app/build.gradle`
- For iOS: Run `flutter doctor -v`

---

## 📱 API Testing with Postman

### Import Collection

1. Open Postman
2. Import this collection:
   - File → Import → Raw text
   - Paste the JSON below:

```json
{
  "info": {
    "name": "Auth App API",
    "version": "1.0.0"
  },
  "item": [
    {
      "name": "Register",
      "request": {
        "method": "POST",
        "url": {
          "raw": "http://localhost:5000/api/auth/register",
          "protocol": "http",
          "host": ["localhost"],
          "port": "5000",
          "path": ["api", "auth", "register"]
        },
        "body": {
          "mode": "raw",
          "raw": "{\"name\":\"Test User\",\"email\":\"test@example.com\",\"password\":\"password123\",\"confirmPassword\":\"password123\"}"
        }
      }
    },
    {
      "name": "Login",
      "request": {
        "method": "POST",
        "url": {
          "raw": "http://localhost:5000/api/auth/login",
          "protocol": "http",
          "host": ["localhost"],
          "port": "5000",
          "path": ["api", "auth", "login"]
        },
        "body": {
          "mode": "raw",
          "raw": "{\"email\":\"test@example.com\",\"password\":\"password123\"}"
        }
      }
    }
  ]
}
```

---

## 🎯 Next Steps

After successful testing:

1. **Customize UI**
   - Update colors in `main.dart`
   - Add app logo/icon
   - Customize fonts and typography

2. **Add Features**
   - Password reset via email
   - Profile update functionality
   - Social login (Google, Apple)
   - Two-factor authentication

3. **Deploy**
   - Backend: Heroku, Railway, or AWS
   - Database: AWS RDS or Digital Ocean
   - Frontend: Google Play Store & Apple App Store

4. **Monitor**
   - Set up error tracking (Sentry)
   - Add analytics
   - Monitor API performance

---

## ✅ Verification Checklist

- [ ] MySQL database created
- [ ] Backend running on port 5000
- [ ] Flutter app runs without errors
- [ ] Can register new user
- [ ] Can login with credentials
- [ ] Can view profile
- [ ] Can logout
- [ ] Tokens persist after restart

---

**Need Help?** Check the `COMPLETE_DOCUMENTATION.md` for detailed info.

# Authentication Backend - Express.js

Production-ready authentication backend built with Express.js and MySQL.

## Project Structure

```
backend/
├── config/
│   └── database.js          # MySQL connection pool
├── controllers/
│   └── authController.js    # Request handlers
├── middleware/
│   └── authMiddleware.js    # JWT verification & error handling
├── routes/
│   └── authRoutes.js        # API route definitions
├── services/
│   └── authService.js       # Business logic
├── .env.example             # Environment variables template
├── app.js                   # Express app configuration
├── server.js                # Server entry point
└── package.json             # Dependencies
```

## Installation

1. **Install dependencies:**
   ```bash
   npm install
   ```

2. **Set up environment variables:**
   ```bash
   cp .env.example .env
   ```
   Edit `.env` with your database credentials and secrets:
   ```
   PORT=5000
   DB_HOST=localhost
   DB_USER=root
   DB_PASSWORD=your_password
   DB_NAME=auth_app_db
   JWT_ACCESS_SECRET=your_secret_key
   JWT_REFRESH_SECRET=your_refresh_secret
   ```

3. **Create MySQL database:**
   ```bash
   mysql -u root -p < ../database_schema.sql
   ```

## Running

**Development mode (with auto-reload):**
```bash
npm run dev
```

**Production mode:**
```bash
npm start
```

Server will start at `http://localhost:5000`

## API Endpoints

### Public Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/auth/register` | User registration |
| POST | `/api/auth/login` | User login |
| POST | `/api/auth/refresh-token` | Refresh access token |
| POST | `/api/auth/logout` | User logout |

### Protected Endpoints

| Method | Endpoint | Description | Headers |
|--------|----------|-------------|---------|
| GET | `/api/user/profile` | Get user profile | `Authorization: Bearer {token}` |

## API Response Format

All responses follow this format:

```json
{
  "success": true/false,
  "message": "Description",
  "data": {} // Optional
}
```

## Security Features

- ✓ Bcrypt password hashing
- ✓ JWT access tokens (short-lived)
- ✓ JWT refresh tokens (long-lived, stored in DB)
- ✓ Token verification middleware
- ✓ CORS protection
- ✓ Environment variable security
- ✓ HTTP-only cookies for refresh tokens (optional)

## Database

- MySQL with connection pooling
- Foreign key relationships
- Automatic timestamp tracking
- Indexed queries for performance

## Error Handling

- Comprehensive error messages
- Proper HTTP status codes
- Request validation
- Try-catch error boundaries

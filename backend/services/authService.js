const bcryptjs = require('bcryptjs');
const jwt = require('jsonwebtoken');
const pool = require('../config/database');

// ============================================
// Register Service
// ============================================
async function register(name, email, password) {
  try {
    // Check if user already exists
    const [existingUser] = await pool.query(
      'SELECT id FROM users WHERE email = ?',
      [email]
    );

    if (existingUser.length > 0) {
      return {
        success: false,
        message: 'Email already registered',
        statusCode: 409,
      };
    }

    // Hash password
    const hashedPassword = await bcryptjs.hash(password, 10);

    // Insert user
    const [result] = await pool.query(
      'INSERT INTO users (name, email, password_hash) VALUES (?, ?, ?)',
      [name, email, hashedPassword]
    );

    return {
      success: true,
      message: 'User registered successfully',
      statusCode: 201,
      userId: result.insertId,
    };
  } catch (error) {
    console.error('Register error:', error);
    return {
      success: false,
      message: 'Registration failed',
      statusCode: 500,
      error: error.message,
    };
  }
}

// ============================================
// Login Service
// ============================================
async function login(email, password) {
  try {
    // Find user by email
    const [users] = await pool.query(
      'SELECT id, name, email, password_hash FROM users WHERE email = ?',
      [email]
    );

    if (users.length === 0) {
      return {
        success: false,
        message: 'Invalid email or password',
        statusCode: 401,
      };
    }

    const user = users[0];

    // Verify password
    const isPasswordValid = await bcryptjs.compare(password, user.password_hash);
    if (!isPasswordValid) {
      return {
        success: false,
        message: 'Invalid email or password',
        statusCode: 401,
      };
    }

    // Generate tokens
    const accessToken = jwt.sign(
      { userId: user.id, email: user.email },
      process.env.JWT_ACCESS_SECRET,
      { expiresIn: process.env.JWT_ACCESS_EXPIRY }
    );

    const refreshToken = jwt.sign(
      { userId: user.id },
      process.env.JWT_REFRESH_SECRET,
      { expiresIn: process.env.JWT_REFRESH_EXPIRY }
    );

    // Store refresh token in database
    const expiresAt = new Date(Date.now() + 7 * 24 * 60 * 60 * 1000); // 7 days
    await pool.query(
      'INSERT INTO refresh_tokens (user_id, token, expires_at) VALUES (?, ?, ?)',
      [user.id, refreshToken, expiresAt]
    );

    return {
      success: true,
      message: 'Login successful',
      statusCode: 200,
      data: {
        userId: user.id,
        name: user.name,
        email: user.email,
        accessToken,
        refreshToken,
      },
    };
  } catch (error) {
    console.error('Login error:', error);
    return {
      success: false,
      message: 'Login failed',
      statusCode: 500,
      error: error.message,
    };
  }
}

// ============================================
// Refresh Token Service
// ============================================
async function refreshAccessToken(refreshToken) {
  try {
    // Verify refresh token
    const decoded = jwt.verify(refreshToken, process.env.JWT_REFRESH_SECRET);

    // Check if token exists in database and is not expired
    const [tokens] = await pool.query(
      'SELECT id FROM refresh_tokens WHERE user_id = ? AND token = ? AND expires_at > NOW()',
      [decoded.userId, refreshToken]
    );

    if (tokens.length === 0) {
      return {
        success: false,
        message: 'Invalid or expired refresh token',
        statusCode: 401,
      };
    }

    // Get user info
    const [users] = await pool.query(
      'SELECT id, email FROM users WHERE id = ?',
      [decoded.userId]
    );

    if (users.length === 0) {
      return {
        success: false,
        message: 'User not found',
        statusCode: 404,
      };
    }

    const user = users[0];

    // Generate new access token
    const newAccessToken = jwt.sign(
      { userId: user.id, email: user.email },
      process.env.JWT_ACCESS_SECRET,
      { expiresIn: process.env.JWT_ACCESS_EXPIRY }
    );

    return {
      success: true,
      message: 'Access token refreshed',
      statusCode: 200,
      data: {
        accessToken: newAccessToken,
      },
    };
  } catch (error) {
    console.error('Refresh token error:', error);
    return {
      success: false,
      message: 'Token refresh failed',
      statusCode: 401,
      error: error.message,
    };
  }
}

// ============================================
// Logout Service
// ============================================
async function logout(refreshToken) {
  try {
    // Remove refresh token from database
    const [result] = await pool.query(
      'DELETE FROM refresh_tokens WHERE token = ?',
      [refreshToken]
    );

    if (result.affectedRows === 0) {
      return {
        success: false,
        message: 'Refresh token not found',
        statusCode: 404,
      };
    }

    return {
      success: true,
      message: 'Logout successful',
      statusCode: 200,
    };
  } catch (error) {
    console.error('Logout error:', error);
    return {
      success: false,
      message: 'Logout failed',
      statusCode: 500,
      error: error.message,
    };
  }
}

// ============================================
// Get User Profile Service
// ============================================
async function getUserProfile(userId) {
  try {
    const [users] = await pool.query(
      'SELECT id, name, email, created_at, updated_at FROM users WHERE id = ?',
      [userId]
    );

    if (users.length === 0) {
      return {
        success: false,
        message: 'User not found',
        statusCode: 404,
      };
    }

    return {
      success: true,
      message: 'Profile fetched successfully',
      statusCode: 200,
      data: users[0],
    };
  } catch (error) {
    console.error('Get profile error:', error);
    return {
      success: false,
      message: 'Failed to fetch profile',
      statusCode: 500,
      error: error.message,
    };
  }
}

module.exports = {
  register,
  login,
  refreshAccessToken,
  logout,
  getUserProfile,
};

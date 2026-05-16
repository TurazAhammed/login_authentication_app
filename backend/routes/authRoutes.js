const express = require('express');
const authController = require('../controllers/authController');
const { verifyAccessToken } = require('../middleware/authMiddleware');

const router = express.Router();

// ============================================
// Public Routes
// ============================================

// POST /api/auth/register
router.post('/register', authController.register);

// POST /api/auth/login
router.post('/login', authController.login);

// POST /api/auth/refresh-token
router.post('/refresh-token', authController.refreshToken);

// POST /api/auth/logout
router.post('/logout', authController.logout);

// ============================================
// Protected Routes
// ============================================

// GET /api/user/profile
router.get('/profile', verifyAccessToken, authController.getProfile);

module.exports = router;

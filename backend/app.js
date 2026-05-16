require('dotenv').config();
const express = require('express');
const cors = require('cors');
const authRoutes = require('./routes/authRoutes');
const { errorHandler } = require('./middleware/authMiddleware');

const app = express();

// ============================================
// Middleware
// ============================================

// Body parser
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// CORS
app.use(
  // Allow requests from the frontend during development. When in development
  // mode, reflect the request origin (true) so Flutter web served from any
  // localhost port can make requests. In production, use the configured origin.
  cors({
    origin: process.env.NODE_ENV === 'development' ? true : process.env.CORS_ORIGIN,
    credentials: true,
  })
);

// ============================================
// Routes
// ============================================

// Health check endpoint
app.get('/api/health', (req, res) => {
  res.status(200).json({
    success: true,
    message: 'Server is running',
  });
});

// Authentication routes
app.use('/api/auth', authRoutes);

// ============================================
// Not Found Route
// ============================================
app.use('*', (req, res) => {
  res.status(404).json({
    success: false,
    message: 'Route not found',
  });
});

// ============================================
// Error Handler
// ============================================
app.use(errorHandler);

module.exports = app;

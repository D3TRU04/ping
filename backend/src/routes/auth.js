const express = require('express');
const { authenticateToken } = require('../middleware/auth');
const { 
  getUserProfile, 
  updateUserProfile, 
  checkUsernameAvailability 
} = require('../controllers/authController');

const router = express.Router();

// Protected routes (require authentication)
router.get('/profile', authenticateToken, getUserProfile);
router.put('/profile', authenticateToken, updateUserProfile);

// Public routes
router.get('/username/:username/availability', checkUsernameAvailability);

module.exports = router; 
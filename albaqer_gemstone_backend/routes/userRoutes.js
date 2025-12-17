const express = require('express');
const router = express.Router();
const {
    registerUser,
    loginUser,
    getUserProfile,
    updateUserProfile,
    getAllUsers
} = require('../controllers/userController');
const { protect, admin } = require('../middleware/auth');
const { validateUserRegister, validateUserLogin } = require('../middleware/validation');
const { asyncHandler } = require('../middleware/errorHandler');

// Public routes
router.post('/register', validateUserRegister, asyncHandler(registerUser));
router.post('/login', validateUserLogin, asyncHandler(loginUser));

// Admin routes (must come before other GET routes)
router.get('/all', protect, admin, asyncHandler(getAllUsers));

// Private routes
router.get('/profile', protect, asyncHandler(getUserProfile));
router.put('/profile', protect, validateUserRegister, asyncHandler(updateUserProfile));

module.exports = router;

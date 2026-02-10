const express = require('express');
const router = express.Router();
const {
    registerUser,
    loginUser,
    getUserProfile,
    updateUserProfile,
    getAllUsers,
    assignRoleToUser,
    getDeliveryMenList,
    getManagersList
} = require('../controllers/userController');
const { protect, admin } = require('../middleware/auth');
const { validateUserRegister, validateUserLogin } = require('../middleware/validation');
const { asyncHandler } = require('../middleware/errorHandler');

// Public routes
router.post('/register', validateUserRegister, asyncHandler(registerUser));
router.post('/login', validateUserLogin, asyncHandler(loginUser));

// Admin routes (must come before other GET routes)
router.get('/all', protect, admin, asyncHandler(getAllUsers));
router.get('/role/delivery-men', protect, admin, asyncHandler(getDeliveryMenList));
router.get('/role/managers', protect, admin, asyncHandler(getManagersList));
router.put('/:id/assign-role', protect, admin, asyncHandler(assignRoleToUser));

// Private routes
router.get('/profile', protect, asyncHandler(getUserProfile));
router.put('/profile', protect, validateUserRegister, asyncHandler(updateUserProfile));

module.exports = router;

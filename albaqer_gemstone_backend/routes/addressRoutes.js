const express = require('express');
const router = express.Router();
const {
    getUserAddresses,
    getAddressById,
    getDefaultAddress,
    createAddress,
    updateAddress,
    setDefaultAddress,
    deleteAddress,
    getAddressesByUserId
} = require('../controllers/addressController');
const { protect, admin } = require('../middleware/auth');
const { validateAddress, validateId } = require('../middleware/validation');
const { asyncHandler } = require('../middleware/errorHandler');

// Admin routes (must come before other routes)
router.get('/user/:userId', protect, admin, asyncHandler(getAddressesByUserId));

// Private routes - must be authenticated
router.get('/', protect, asyncHandler(getUserAddresses));
router.get('/default', protect, asyncHandler(getDefaultAddress));
router.get('/:id', protect, validateId, asyncHandler(getAddressById));
router.post('/', protect, validateAddress, asyncHandler(createAddress));
router.put('/:id', protect, validateId, validateAddress, asyncHandler(updateAddress));
router.put('/:id/set-default', protect, validateId, asyncHandler(setDefaultAddress));
router.delete('/:id', protect, validateId, asyncHandler(deleteAddress));

module.exports = router;

const express = require('express');
const router = express.Router();
const {
    getCart,
    addToCart,
    updateCartItem,
    removeFromCart,
    clearCart
} = require('../controllers/cartController');
const { protect } = require('../middleware/auth');
const { asyncHandler } = require('../middleware/errorHandler');

// All cart routes require authentication
router.use(protect);

// Get user's cart
router.get('/', asyncHandler(getCart));

// Add item to cart
router.post('/items', asyncHandler(addToCart));

// Update cart item quantity
router.put('/items/:id', asyncHandler(updateCartItem));

// Remove item from cart
router.delete('/items/:id', asyncHandler(removeFromCart));

// Clear entire cart
router.delete('/', asyncHandler(clearCart));

module.exports = router;

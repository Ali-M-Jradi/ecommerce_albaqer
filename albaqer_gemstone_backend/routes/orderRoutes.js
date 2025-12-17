const express = require('express');
const router = express.Router();
const {
    getAllOrders,
    getMyOrders,
    getOrderById,
    createOrder,
    updateOrderStatus,
    deleteOrder
} = require('../controllers/orderController');
const { protect, admin } = require('../middleware/auth');
const { validateOrder, validateId } = require('../middleware/validation');
const { asyncHandler } = require('../middleware/errorHandler');

// Admin routes (must come before specific routes)
router.get('/all', protect, admin, asyncHandler(getAllOrders));

// Private routes
router.get('/my-orders', protect, asyncHandler(getMyOrders));
router.get('/:id', protect, validateId, asyncHandler(getOrderById));
router.post('/', protect, validateOrder, asyncHandler(createOrder));
router.put('/:id/status', protect, admin, validateId, asyncHandler(updateOrderStatus));
router.delete('/:id', protect, admin, validateId, asyncHandler(deleteOrder));

module.exports = router;

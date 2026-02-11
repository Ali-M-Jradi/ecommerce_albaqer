const express = require('express');
const router = express.Router();
const {
    getAllOrders,
    getMyOrders,
    getOrderById,
    createOrder,
    updateOrderStatus,
    deleteOrder,
    // Manager functions
    getPendingOrders,
    getDeliveryMen,
    assignOrderToDelivery,
    getDeliveryManOrders,
    unassignOrderFromDelivery,
    // Inventory monitoring
    getLowStockProducts
} = require('../controllers/orderController');
const { protect, admin, manager, managerOrAdmin } = require('../middleware/auth');
const { validateOrder, validateId } = require('../middleware/validation');
const { asyncHandler } = require('../middleware/errorHandler');

// Admin and Manager routes (must come before specific routes)
router.get('/all', protect, managerOrAdmin, asyncHandler(getAllOrders));
router.get('/inventory/low-stock', protect, admin, asyncHandler(getLowStockProducts));

// Manager routes
router.get('/manager/pending', protect, manager, asyncHandler(getPendingOrders));
router.get('/manager/delivery-men', protect, manager, asyncHandler(getDeliveryMen));
router.get('/manager/delivery-man/:deliveryManId', protect, manager, asyncHandler(getDeliveryManOrders));
router.put('/:id/assign-delivery', protect, manager, validateId, asyncHandler(assignOrderToDelivery));
router.put('/:id/unassign-delivery', protect, manager, validateId, asyncHandler(unassignOrderFromDelivery));

// Private routes
router.get('/my-orders', protect, asyncHandler(getMyOrders));
router.get('/:id', protect, validateId, asyncHandler(getOrderById));
router.post('/', protect, validateOrder, asyncHandler(createOrder));
router.put('/:id/status', protect, admin, validateId, asyncHandler(updateOrderStatus));
router.delete('/:id', protect, admin, validateId, asyncHandler(deleteOrder));

module.exports = router;

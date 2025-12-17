const express = require('express');
const router = express.Router();
const {
    getAllProducts,
    getProductById,
    createProduct,
    updateProduct,
    deleteProduct,
    searchProducts
} = require('../controllers/productController');
const { protect, admin } = require('../middleware/auth');
const { validateProduct, validateId } = require('../middleware/validation');
const { asyncHandler } = require('../middleware/errorHandler');

// Public routes
router.get('/', asyncHandler(getAllProducts));
router.get('/search', asyncHandler(searchProducts));
router.get('/:id', validateId, asyncHandler(getProductById));

// Admin only routes
router.post('/', protect, admin, validateProduct, asyncHandler(createProduct));
router.put('/:id', protect, admin, validateId, validateProduct, asyncHandler(updateProduct));
router.delete('/:id', protect, admin, validateId, asyncHandler(deleteProduct));

module.exports = router;

const express = require('express');
const router = express.Router();
const {
    createReview,
    getReviews,
    getReviewById,
    updateReview,
    deleteReview
} = require('../controllers/reviewController');
const { protect } = require('../middleware/auth');
const { asyncHandler } = require('../middleware/errorHandler');

// Public routes
router.get('/', asyncHandler(getReviews));
router.get('/:id', asyncHandler(getReviewById));

// Protected routes (must be logged in)
router.post('/', protect, asyncHandler(createReview));
router.put('/:id', protect, asyncHandler(updateReview));
router.delete('/:id', protect, asyncHandler(deleteReview));

module.exports = router;

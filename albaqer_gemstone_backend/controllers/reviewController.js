const pool = require('../db/connection');

// ========== CREATE ==========

// @desc    Create a new review
// @route   POST /api/reviews
// @access  Private (must be logged in)
const createReview = async (req, res) => {
    try {
        const {
            product_id,
            order_id,
            rating,
            title,
            comment
        } = req.body;

        const user_id = req.user.id;

        // Validation: Rating must be between 1 and 5
        if (!rating || rating < 1 || rating > 5) {
            return res.status(400).json({
                success: false,
                message: 'Rating must be between 1 and 5'
            });
        }

        // Validation: Product ID is required
        if (!product_id) {
            return res.status(400).json({
                success: false,
                message: 'Product ID is required'
            });
        }

        // Check if product exists
        const productCheck = await pool.query(
            'SELECT id FROM products WHERE id = $1',
            [product_id]
        );

        if (productCheck.rowCount === 0) {
            return res.status(404).json({
                success: false,
                message: 'Product not found'
            });
        }

        // Check if user already reviewed this product
        const existingReview = await pool.query(
            'SELECT id FROM reviews WHERE user_id = $1 AND product_id = $2',
            [user_id, product_id]
        );

        if (existingReview.rowCount > 0) {
            return res.status(400).json({
                success: false,
                message: 'You have already reviewed this product. You can update your existing review instead.'
            });
        }

        // Verify purchase: Check if user has ordered this product (optional but recommended)
        let is_verified_purchase = false;
        if (order_id) {
            const orderCheck = await pool.query(
                `SELECT o.id FROM orders o
                 JOIN order_items oi ON o.id = oi.order_id
                 WHERE o.user_id = $1 AND oi.product_id = $2 AND o.id = $3`,
                [user_id, product_id, order_id]
            );
            is_verified_purchase = orderCheck.rowCount > 0;
        } else {
            // Check any order by this user for this product
            const anyOrderCheck = await pool.query(
                `SELECT o.id FROM orders o
                 JOIN order_items oi ON o.id = oi.order_id
                 WHERE o.user_id = $1 AND oi.product_id = $2
                 LIMIT 1`,
                [user_id, product_id]
            );
            is_verified_purchase = anyOrderCheck.rowCount > 0;
        }

        // Create review
        const result = await pool.query(
            `INSERT INTO reviews (user_id, product_id, order_id, rating, title, comment, is_verified_purchase)
             VALUES ($1, $2, $3, $4, $5, $6, $7)
             RETURNING *`,
            [user_id, product_id, order_id, rating, title, comment, is_verified_purchase]
        );

        console.log('✅ Review created:', result.rows[0].id);

        // Update product average rating
        await updateProductRating(product_id);

        res.status(201).json({
            success: true,
            message: 'Review created successfully',
            data: result.rows[0]
        });
    } catch (error) {
        console.error('Error creating review:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to create review',
            error: error.message
        });
    }
};

// ========== READ (ALL/FILTERED) ==========

// @desc    Get all reviews or filtered by product_id or user_id
// @route   GET /api/reviews?product_id=X&user_id=Y
// @access  Public
const getReviews = async (req, res) => {
    try {
        const { product_id, user_id } = req.query;

        let query = `
            SELECT r.*, u.full_name as user_name
            FROM reviews r
            JOIN users u ON r.user_id = u.id
            WHERE 1=1
        `;
        const params = [];

        // Filter by product_id if provided
        if (product_id) {
            params.push(product_id);
            query += ` AND r.product_id = $${params.length}`;
        }

        // Filter by user_id if provided
        if (user_id) {
            params.push(user_id);
            query += ` AND r.user_id = $${params.length}`;
        }

        query += ` ORDER BY r.created_at DESC`;

        const result = await pool.query(query, params);

        res.json({
            success: true,
            data: result.rows,
            count: result.rowCount
        });
    } catch (error) {
        console.error('Error fetching reviews:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to fetch reviews',
            error: error.message
        });
    }
};

// ========== READ (BY ID) ==========

// @desc    Get a single review by ID
// @route   GET /api/reviews/:id
// @access  Public
const getReviewById = async (req, res) => {
    try {
        const { id } = req.params;

        const result = await pool.query(
            `SELECT r.*, u.full_name as user_name
             FROM reviews r
             JOIN users u ON r.user_id = u.id
             WHERE r.id = $1`,
            [id]
        );

        if (result.rowCount === 0) {
            return res.status(404).json({
                success: false,
                message: 'Review not found'
            });
        }

        res.json({
            success: true,
            data: result.rows[0]
        });
    } catch (error) {
        console.error('Error fetching review:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to fetch review',
            error: error.message
        });
    }
};

// ========== UPDATE ==========

// @desc    Update a review
// @route   PUT /api/reviews/:id
// @access  Private (must be owner or admin)
const updateReview = async (req, res) => {
    try {
        const { id } = req.params;
        const { rating, title, comment } = req.body;

        // Check if review exists
        const reviewCheck = await pool.query(
            'SELECT * FROM reviews WHERE id = $1',
            [id]
        );

        if (reviewCheck.rowCount === 0) {
            return res.status(404).json({
                success: false,
                message: 'Review not found'
            });
        }

        const review = reviewCheck.rows[0];

        // Check authorization (must be owner or admin)
        if (review.user_id !== req.user.id && req.user.role !== 'admin') {
            return res.status(403).json({
                success: false,
                message: 'Not authorized to update this review'
            });
        }

        // Validation: Rating must be between 1 and 5
        if (rating && (rating < 1 || rating > 5)) {
            return res.status(400).json({
                success: false,
                message: 'Rating must be between 1 and 5'
            });
        }

        // Update review
        const result = await pool.query(
            `UPDATE reviews
             SET rating = COALESCE($1, rating),
                 title = COALESCE($2, title),
                 comment = COALESCE($3, comment),
                 updated_at = CURRENT_TIMESTAMP
             WHERE id = $4
             RETURNING *`,
            [rating, title, comment, id]
        );

        console.log('✅ Review updated:', id);

        // Update product average rating
        await updateProductRating(review.product_id);

        res.json({
            success: true,
            message: 'Review updated successfully',
            data: result.rows[0]
        });
    } catch (error) {
        console.error('Error updating review:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to update review',
            error: error.message
        });
    }
};

// ========== DELETE ==========

// @desc    Delete a review
// @route   DELETE /api/reviews/:id
// @access  Private (must be owner or admin)
const deleteReview = async (req, res) => {
    try {
        const { id } = req.params;

        // Check if review exists
        const reviewCheck = await pool.query(
            'SELECT * FROM reviews WHERE id = $1',
            [id]
        );

        if (reviewCheck.rowCount === 0) {
            return res.status(404).json({
                success: false,
                message: 'Review not found'
            });
        }

        const review = reviewCheck.rows[0];

        // Check authorization (must be owner or admin)
        if (review.user_id !== req.user.id && req.user.role !== 'admin') {
            return res.status(403).json({
                success: false,
                message: 'Not authorized to delete this review'
            });
        }

        // Delete review
        await pool.query('DELETE FROM reviews WHERE id = $1', [id]);

        console.log('✅ Review deleted:', id);

        // Update product average rating
        await updateProductRating(review.product_id);

        res.json({
            success: true,
            message: 'Review deleted successfully'
        });
    } catch (error) {
        console.error('Error deleting review:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to delete review',
            error: error.message
        });
    }
};

// ========== HELPER FUNCTION ==========

/**
 * Update product's average rating and review count
 * Called after creating, updating, or deleting a review
 */
const updateProductRating = async (product_id) => {
    try {
        const result = await pool.query(
            `SELECT 
                AVG(rating)::NUMERIC(3,2) as avg_rating,
                COUNT(*) as review_count
             FROM reviews
             WHERE product_id = $1`,
            [product_id]
        );

        const avg_rating = result.rows[0].avg_rating || 0;
        const review_count = parseInt(result.rows[0].review_count) || 0;

        await pool.query(
            `UPDATE products
             SET average_rating = $1,
                 review_count = $2,
                 updated_at = CURRENT_TIMESTAMP
             WHERE id = $3`,
            [avg_rating, review_count, product_id]
        );

        console.log(`📊 Product #${product_id} rating updated: ${avg_rating} (${review_count} reviews)`);
    } catch (error) {
        console.error('Error updating product rating:', error);
        // Don't throw error - this is a helper function
    }
};

module.exports = {
    createReview,
    getReviews,
    getReviewById,
    updateReview,
    deleteReview
};

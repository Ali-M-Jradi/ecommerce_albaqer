const pool = require('../db/connection');

// @desc    Get user's cart with all items and product details
// @route   GET /api/cart
// @access  Private
const getCart = async (req, res) => {
    try {
        const userId = req.user.id;

        // Get or create cart for user
        let cartResult = await pool.query(
            'SELECT * FROM carts WHERE user_id = $1',
            [userId]
        );

        let cart;
        if (cartResult.rowCount === 0) {
            // Create cart if doesn't exist
            const newCart = await pool.query(
                'INSERT INTO carts (user_id) VALUES ($1) RETURNING *',
                [userId]
            );
            cart = newCart.rows[0];
        } else {
            cart = cartResult.rows[0];
        }

        // Get cart items with product details
        const cartItems = await pool.query(
            `SELECT 
                ci.id,
                ci.cart_id,
                ci.product_id,
                ci.quantity,
                ci.price_at_add,
                p.name as product_name,
                p.type as product_type,
                p.description as product_description,
                p.image_url as product_image,
                p.quantity_in_stock as product_in_stock,
                p.base_price as current_price
            FROM cart_items ci
            JOIN products p ON ci.product_id = p.id
            WHERE ci.cart_id = $1
            ORDER BY ci.id DESC`,
            [cart.id]
        );

        res.json({
            success: true,
            data: {
                cart_id: cart.id,
                items: cartItems.rows,
                item_count: cartItems.rowCount
            }
        });
    } catch (error) {
        console.error('Error getting cart:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to get cart',
            error: error.message
        });
    }
};

// @desc    Add item to cart
// @route   POST /api/cart/items
// @access  Private
const addToCart = async (req, res) => {
    try {
        const userId = req.user.id;
        const { product_id, quantity = 1 } = req.body;

        if (!product_id) {
            return res.status(400).json({
                success: false,
                message: 'Product ID is required'
            });
        }

        // Validate product exists and has stock
        const product = await pool.query(
            'SELECT * FROM products WHERE id = $1',
            [product_id]
        );

        if (product.rowCount === 0) {
            return res.status(404).json({
                success: false,
                message: 'Product not found'
            });
        }

        const productData = product.rows[0];

        if (productData.quantity_in_stock < quantity) {
            return res.status(400).json({
                success: false,
                message: `Only ${productData.quantity_in_stock} items available in stock`
            });
        }

        // Get or create cart
        let cartResult = await pool.query(
            'SELECT * FROM carts WHERE user_id = $1',
            [userId]
        );

        let cartId;
        if (cartResult.rowCount === 0) {
            const newCart = await pool.query(
                'INSERT INTO carts (user_id) VALUES ($1) RETURNING id',
                [userId]
            );
            cartId = newCart.rows[0].id;
        } else {
            cartId = cartResult.rows[0].id;
        }

        // Check if product already in cart
        const existingItem = await pool.query(
            'SELECT * FROM cart_items WHERE cart_id = $1 AND product_id = $2',
            [cartId, product_id]
        );

        let cartItem;
        if (existingItem.rowCount > 0) {
            // Update quantity
            const newQuantity = existingItem.rows[0].quantity + quantity;

            if (newQuantity > productData.quantity_in_stock) {
                return res.status(400).json({
                    success: false,
                    message: 'Cannot add more items. Stock limit reached'
                });
            }

            const updated = await pool.query(
                `UPDATE cart_items 
                 SET quantity = $1, updated_at = CURRENT_TIMESTAMP
                 WHERE cart_id = $2 AND product_id = $3
                 RETURNING *`,
                [newQuantity, cartId, product_id]
            );
            cartItem = updated.rows[0];
        } else {
            // Add new item
            const inserted = await pool.query(
                `INSERT INTO cart_items (cart_id, product_id, quantity, price_at_add)
                 VALUES ($1, $2, $3, $4)
                 RETURNING *`,
                [cartId, product_id, quantity, productData.base_price]
            );
            cartItem = inserted.rows[0];
        }

        res.status(201).json({
            success: true,
            message: 'Item added to cart',
            data: cartItem
        });
    } catch (error) {
        console.error('Error adding to cart:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to add item to cart',
            error: error.message
        });
    }
};

// @desc    Update cart item quantity
// @route   PUT /api/cart/items/:id
// @access  Private
const updateCartItem = async (req, res) => {
    try {
        const userId = req.user.id;
        const itemId = req.params.id;
        const { quantity } = req.body;

        if (!quantity || quantity < 1) {
            return res.status(400).json({
                success: false,
                message: 'Quantity must be at least 1'
            });
        }

        // Verify item belongs to user's cart
        const item = await pool.query(
            `SELECT ci.*, c.user_id, p.quantity_in_stock
             FROM cart_items ci
             JOIN carts c ON ci.cart_id = c.id
             JOIN products p ON ci.product_id = p.id
             WHERE ci.id = $1`,
            [itemId]
        );

        if (item.rowCount === 0) {
            return res.status(404).json({
                success: false,
                message: 'Cart item not found'
            });
        }

        if (item.rows[0].user_id !== userId) {
            return res.status(403).json({
                success: false,
                message: 'Unauthorized'
            });
        }

        if (quantity > item.rows[0].quantity_in_stock) {
            return res.status(400).json({
                success: false,
                message: `Only ${item.rows[0].quantity_in_stock} items available`
            });
        }

        // Update quantity
        const updated = await pool.query(
            `UPDATE cart_items 
             SET quantity = $1, updated_at = CURRENT_TIMESTAMP
             WHERE id = $2
             RETURNING *`,
            [quantity, itemId]
        );

        res.json({
            success: true,
            message: 'Cart item updated',
            data: updated.rows[0]
        });
    } catch (error) {
        console.error('Error updating cart item:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to update cart item',
            error: error.message
        });
    }
};

// @desc    Remove item from cart
// @route   DELETE /api/cart/items/:id
// @access  Private
const removeFromCart = async (req, res) => {
    try {
        const userId = req.user.id;
        const itemId = req.params.id;

        // Verify item belongs to user's cart
        const item = await pool.query(
            `SELECT ci.*, c.user_id
             FROM cart_items ci
             JOIN carts c ON ci.cart_id = c.id
             WHERE ci.id = $1`,
            [itemId]
        );

        if (item.rowCount === 0) {
            return res.status(404).json({
                success: false,
                message: 'Cart item not found'
            });
        }

        if (item.rows[0].user_id !== userId) {
            return res.status(403).json({
                success: false,
                message: 'Unauthorized'
            });
        }

        // Delete item
        await pool.query('DELETE FROM cart_items WHERE id = $1', [itemId]);

        res.json({
            success: true,
            message: 'Item removed from cart'
        });
    } catch (error) {
        console.error('Error removing from cart:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to remove item from cart',
            error: error.message
        });
    }
};

// @desc    Clear entire cart
// @route   DELETE /api/cart
// @access  Private
const clearCart = async (req, res) => {
    try {
        const userId = req.user.id;

        // Get cart
        const cart = await pool.query(
            'SELECT id FROM carts WHERE user_id = $1',
            [userId]
        );

        if (cart.rowCount > 0) {
            // Delete all items
            await pool.query(
                'DELETE FROM cart_items WHERE cart_id = $1',
                [cart.rows[0].id]
            );
        }

        res.json({
            success: true,
            message: 'Cart cleared'
        });
    } catch (error) {
        console.error('Error clearing cart:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to clear cart',
            error: error.message
        });
    }
};

module.exports = {
    getCart,
    addToCart,
    updateCartItem,
    removeFromCart,
    clearCart
};

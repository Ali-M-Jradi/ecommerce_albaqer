const pool = require('../db/connection');

// @desc    Get all orders
// @route   GET /api/orders
// @access  Private/Admin
const getAllOrders = async (req, res) => {
    const result = await pool.query(
        'SELECT * FROM orders ORDER BY created_at DESC'
    );

    res.json({
        success: true,
        data: result.rows,
        count: result.rowCount
    });
};

// @desc    Get user's orders
// @route   GET /api/orders/my-orders
// @access  Private
const getMyOrders = async (req, res) => {
    const result = await pool.query(
        'SELECT * FROM orders WHERE user_id = $1 ORDER BY created_at DESC',
        [req.user.id]
    );

    res.json({
        success: true,
        data: result.rows,
        count: result.rowCount
    });
};

// @desc    Get single order by ID
// @route   GET /api/orders/:id
// @access  Private
const getOrderById = async (req, res) => {
    const { id } = req.params;
    const result = await pool.query('SELECT * FROM orders WHERE id = $1', [id]);

    if (result.rowCount === 0) {
        return res.status(404).json({
            success: false,
            message: 'Order not found'
        });
    }

    const order = result.rows[0];

    // Check if user owns this order or is admin
    if (order.user_id !== req.user.id && req.user.role !== 'admin') {
        return res.status(403).json({
            success: false,
            message: 'Not authorized to view this order'
        });
    }

    res.json({
        success: true,
        data: order
    });
};

// @desc    Create new order
// @route   POST /api/orders
// @access  Private
const createOrder = async (req, res) => {
    const {
        order_number,
        total_amount,
        tax_amount,
        shipping_cost,
        discount_amount,
        shipping_address_id,
        billing_address_id,
        notes
    } = req.body;

    const result = await pool.query(
        `INSERT INTO orders (user_id, order_number, total_amount, tax_amount, shipping_cost, 
                            discount_amount, shipping_address_id, billing_address_id, notes)
         VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
         RETURNING *`,
        [
            req.user.id,
            order_number || `ORD-${Date.now()}`,
            total_amount,
            tax_amount || 0,
            shipping_cost || 0,
            discount_amount || 0,
            shipping_address_id,
            billing_address_id,
            notes
        ]
    );

    res.status(201).json({
        success: true,
        message: 'Order created successfully',
        data: result.rows[0]
    });
};

// @desc    Update order status
// @route   PUT /api/orders/:id/status
// @access  Private/Admin
const updateOrderStatus = async (req, res) => {
    const { id } = req.params;
    const { status, tracking_number } = req.body;

    const result = await pool.query(
        `UPDATE orders 
         SET status = $1, tracking_number = $2, updated_at = CURRENT_TIMESTAMP
         WHERE id = $3
         RETURNING *`,
        [status, tracking_number, id]
    );

    if (result.rowCount === 0) {
        return res.status(404).json({
            success: false,
            message: 'Order not found'
        });
    }

    res.json({
        success: true,
        message: 'Order status updated successfully',
        data: result.rows[0]
    });
};

// @desc    Delete order
// @route   DELETE /api/orders/:id
// @access  Private/Admin
const deleteOrder = async (req, res) => {
    const { id } = req.params;
    const result = await pool.query('DELETE FROM orders WHERE id = $1 RETURNING id', [id]);

    if (result.rowCount === 0) {
        return res.status(404).json({
            success: false,
            message: 'Order not found'
        });
    }

    res.json({
        success: true,
        message: 'Order deleted successfully'
    });
};

module.exports = {
    getAllOrders,
    getMyOrders,
    getOrderById,
    createOrder,
    updateOrderStatus,
    deleteOrder
};

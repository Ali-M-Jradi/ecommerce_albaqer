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

// @desc    Create new order with order items
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
        notes,
        order_items // Array of { product_id, quantity, price_at_purchase }
    } = req.body;

    const client = await pool.connect();

    try {
        await client.query('BEGIN');

        // Create the order
        const orderResult = await client.query(
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
                shipping_address_id || null,
                billing_address_id || null,
                notes
            ]
        );

        const order = orderResult.rows[0];

        // Create order items if provided
        if (order_items && Array.isArray(order_items) && order_items.length > 0) {
            for (const item of order_items) {
                await client.query(
                    `INSERT INTO order_items (order_id, product_id, quantity, price_at_purchase)
                     VALUES ($1, $2, $3, $4)`,
                    [order.id, item.product_id, item.quantity, item.price_at_purchase]
                );

                // Update product inventory (reduce stock)
                await client.query(
                    `UPDATE products 
                     SET quantity_in_stock = quantity_in_stock - $1
                     WHERE id = $2 AND quantity_in_stock >= $1`,
                    [item.quantity, item.product_id]
                );
            }
        }

        await client.query('COMMIT');

        res.status(201).json({
            success: true,
            message: 'Order created successfully',
            data: order
        });
    } catch (error) {
        await client.query('ROLLBACK');
        console.error('Error creating order:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to create order',
            error: error.message
        });
    } finally {
        client.release();
    }
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

// ========== MANAGER FUNCTIONS ==========

// @desc    Get all pending/unassigned orders (for manager)
// @route   GET /api/orders/manager/pending
// @access  Private/Manager
const getPendingOrders = async (req, res) => {
    try {
        const result = await pool.query(
            `SELECT o.* FROM orders o
             WHERE o.status IN ('pending', 'confirmed') OR o.delivery_man_id IS NULL
             ORDER BY o.created_at DESC`
        );

        res.json({
            success: true,
            data: result.rows,
            count: result.rowCount
        });
    } catch (error) {
        console.error('Error fetching pending orders:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to fetch pending orders',
            error: error.message
        });
    }
};

// @desc    Get all delivery men (users with delivery_man role)
// @route   GET /api/orders/manager/delivery-men
// @access  Private/Manager
const getDeliveryMen = async (req, res) => {
    try {
        const result = await pool.query(
            `SELECT id, email, full_name, phone, role, created_at 
             FROM users 
             WHERE role = 'delivery_man'
             ORDER BY full_name ASC`
        );

        res.json({
            success: true,
            data: result.rows,
            count: result.rowCount
        });
    } catch (error) {
        console.error('Error fetching delivery men:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to fetch delivery men',
            error: error.message
        });
    }
};

// @desc    Assign order to delivery man
// @route   PUT /api/orders/:id/assign-delivery
// @access  Private/Manager
const assignOrderToDelivery = async (req, res) => {
    try {
        const { id } = req.params;
        const { delivery_man_id } = req.body;

        // Validate delivery_man_id provided
        if (!delivery_man_id) {
            return res.status(400).json({
                success: false,
                message: 'Delivery man ID is required'
            });
        }

        // Check if order exists
        const orderCheck = await pool.query('SELECT * FROM orders WHERE id = $1', [id]);
        if (orderCheck.rowCount === 0) {
            return res.status(404).json({
                success: false,
                message: 'Order not found'
            });
        }

        // Check if delivery man exists and has correct role
        const deliveryCheck = await pool.query(
            'SELECT * FROM users WHERE id = $1 AND role = $2',
            [delivery_man_id, 'delivery_man']
        );
        if (deliveryCheck.rowCount === 0) {
            return res.status(400).json({
                success: false,
                message: 'Invalid delivery man ID or user is not a delivery man'
            });
        }

        // Update order with delivery_man_id and assigned_at timestamp
        const result = await pool.query(
            `UPDATE orders 
             SET delivery_man_id = $1, assigned_at = CURRENT_TIMESTAMP, status = 'assigned', updated_at = CURRENT_TIMESTAMP
             WHERE id = $2
             RETURNING *`,
            [delivery_man_id, id]
        );

        console.log('✅ Order assigned to delivery man:', { orderId: id, deliveryManId: delivery_man_id });

        res.json({
            success: true,
            message: 'Order assigned to delivery man successfully',
            data: result.rows[0]
        });
    } catch (error) {
        console.error('Error assigning order:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to assign order',
            error: error.message
        });
    }
};

// @desc    Get orders assigned to a specific delivery man
// @route   GET /api/orders/manager/delivery-man/:deliveryManId
// @access  Private/Manager
const getDeliveryManOrders = async (req, res) => {
    try {
        const { deliveryManId } = req.params;

        // Check if delivery man exists
        const deliveryCheck = await pool.query(
            'SELECT * FROM users WHERE id = $1 AND role = $2',
            [deliveryManId, 'delivery_man']
        );
        if (deliveryCheck.rowCount === 0) {
            return res.status(400).json({
                success: false,
                message: 'Invalid delivery man ID'
            });
        }

        const result = await pool.query(
            `SELECT o.* FROM orders o
             WHERE o.delivery_man_id = $1
             ORDER BY o.assigned_at DESC, o.created_at DESC`,
            [deliveryManId]
        );

        res.json({
            success: true,
            data: result.rows,
            count: result.rowCount
        });
    } catch (error) {
        console.error('Error fetching delivery man orders:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to fetch delivery man orders',
            error: error.message
        });
    }
};

// @desc    Unassign order from delivery man
// @route   PUT /api/orders/:id/unassign-delivery
// @access  Private/Manager
const unassignOrderFromDelivery = async (req, res) => {
    try {
        const { id } = req.params;

        const orderCheck = await pool.query('SELECT * FROM orders WHERE id = $1', [id]);
        if (orderCheck.rowCount === 0) {
            return res.status(404).json({
                success: false,
                message: 'Order not found'
            });
        }

        const result = await pool.query(
            `UPDATE orders 
             SET delivery_man_id = NULL, assigned_at = NULL, status = 'confirmed', updated_at = CURRENT_TIMESTAMP
             WHERE id = $1
             RETURNING *`,
            [id]
        );

        console.log('✅ Order unassigned from delivery man:', { orderId: id });

        res.json({
            success: true,
            message: 'Order unassigned from delivery man successfully',
            data: result.rows[0]
        });
    } catch (error) {
        console.error('Error unassigning order:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to unassign order',
            error: error.message
        });
    }
};

module.exports = {
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
    unassignOrderFromDelivery
};

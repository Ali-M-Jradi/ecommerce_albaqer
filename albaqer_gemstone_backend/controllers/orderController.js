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

// @desc    Get orders assigned to delivery person
// @route   GET /api/orders/delivery/my-deliveries
// @access  Private (Delivery Man only)
const getMyDeliveries = async (req, res) => {
    try {
        const result = await pool.query(
            `SELECT o.*, 
                    u.full_name as customer_name, 
                    u.phone as customer_phone,
                    u.email as customer_email
             FROM orders o
             LEFT JOIN users u ON o.user_id = u.id
             WHERE o.delivery_man_id = $1 
             ORDER BY 
                CASE o.status
                    WHEN 'assigned' THEN 1
                    WHEN 'in_transit' THEN 2
                    WHEN 'delivered' THEN 3
                    ELSE 4
                END,
                o.created_at DESC`,
            [req.user.id]
        );

        res.json({
            success: true,
            data: result.rows,
            count: result.rowCount
        });
    } catch (error) {
        console.error('❌ Error fetching delivery orders:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to fetch delivery orders',
            error: error.message
        });
    }
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

    // Check if user owns this order, is admin, is manager, or is the assigned delivery person
    const isAuthorized = order.user_id === req.user.id ||
        req.user.role === 'admin' ||
        req.user.role === 'manager' ||
        (req.user.role === 'delivery_man' && order.delivery_man_id === req.user.id);

    if (!isAuthorized) {
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

// @desc    Get order items for a specific order
// @route   GET /api/orders/:id/items
// @access  Private (Order owner, Admin, Manager, or assigned Delivery Man)
const getOrderItems = async (req, res) => {
    try {
        const { id } = req.params;

        // First check if order exists and user has access
        const orderCheck = await pool.query(
            'SELECT user_id, delivery_man_id FROM orders WHERE id = $1',
            [id]
        );

        if (orderCheck.rowCount === 0) {
            return res.status(404).json({
                success: false,
                message: 'Order not found'
            });
        }

        const order = orderCheck.rows[0];

        // Check authorization
        const isAuthorized = order.user_id === req.user.id ||
            req.user.role === 'admin' ||
            req.user.role === 'manager' ||
            (req.user.role === 'delivery_man' && order.delivery_man_id === req.user.id);

        if (!isAuthorized) {
            return res.status(403).json({
                success: false,
                message: 'Not authorized to view these order items'
            });
        }

        // Get order items with product details
        const result = await pool.query(
            `SELECT oi.*, 
                    p.name as product_name,
                    p.description as product_description,
                    CASE 
                        WHEN p.image_url IS NOT NULL AND p.image_url != '' 
                        THEN CONCAT('http://192.168.0.106:3000', p.image_url)
                        ELSE NULL
                    END as product_image
             FROM order_items oi
             LEFT JOIN products p ON oi.product_id = p.id
             WHERE oi.order_id = $1
             ORDER BY oi.id`,
            [id]
        );

        res.json({
            success: true,
            data: result.rows,
            count: result.rowCount
        });
    } catch (error) {
        console.error('❌ Error fetching order items:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to fetch order items',
            error: error.message
        });
    }
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

        console.log(`📦 Creating order for user #${req.user.id}...`);

        // STEP 1: Validate stock availability for all items BEFORE creating order
        if (order_items && Array.isArray(order_items) && order_items.length > 0) {
            console.log(`🔍 Validating stock for ${order_items.length} items...`);

            const stockIssues = [];
            const lowStockWarnings = [];

            for (const item of order_items) {
                // Check current stock
                const stockCheck = await client.query(
                    `SELECT id, name, quantity_in_stock 
                     FROM products 
                     WHERE id = $1`,
                    [item.product_id]
                );

                if (stockCheck.rows.length === 0) {
                    stockIssues.push({
                        product_id: item.product_id,
                        issue: 'Product not found'
                    });
                    continue;
                }

                const product = stockCheck.rows[0];
                const availableStock = product.quantity_in_stock;

                // Check if sufficient stock
                if (availableStock < item.quantity) {
                    console.error(`❌ Insufficient stock for product #${item.product_id}: requested ${item.quantity}, available ${availableStock}`);
                    stockIssues.push({
                        product_id: item.product_id,
                        product_name: product.name,
                        requested: item.quantity,
                        available: availableStock,
                        issue: 'Insufficient stock'
                    });
                }

                // Check for low stock warning (after order, stock would be below 5)
                if (availableStock - item.quantity < 5 && availableStock - item.quantity >= 0) {
                    lowStockWarnings.push({
                        product_id: item.product_id,
                        product_name: product.name,
                        remaining_after_order: availableStock - item.quantity
                    });
                }
            }

            // If any stock issues, rollback and return error
            if (stockIssues.length > 0) {
                await client.query('ROLLBACK');
                console.error(`❌ Order creation failed: Stock validation errors`);
                return res.status(400).json({
                    success: false,
                    message: 'Cannot create order: Insufficient stock for some items',
                    stock_issues: stockIssues
                });
            }

            // Log low stock warnings
            if (lowStockWarnings.length > 0) {
                console.warn(`⚠️  Low stock warning: ${lowStockWarnings.length} products will be low after this order`);
                lowStockWarnings.forEach(warning => {
                    console.warn(`   - ${warning.product_name} (ID: ${warning.product_id}): ${warning.remaining_after_order} units remaining`);
                });
            }
        }

        // STEP 2: Create the order
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
        console.log(`✅ Order #${order.id} created`);

        // STEP 3: Create order items and update stock
        if (order_items && Array.isArray(order_items) && order_items.length > 0) {
            for (const item of order_items) {
                // Insert order item
                await client.query(
                    `INSERT INTO order_items (order_id, product_id, quantity, price_at_purchase)
                     VALUES ($1, $2, $3, $4)`,
                    [order.id, item.product_id, item.quantity, item.price_at_purchase]
                );

                // Update product inventory (reduce stock)
                const stockUpdateResult = await client.query(
                    `UPDATE products 
                     SET quantity_in_stock = quantity_in_stock - $1,
                         updated_at = CURRENT_TIMESTAMP
                     WHERE id = $2 AND quantity_in_stock >= $1
                     RETURNING id, name, quantity_in_stock`,
                    [item.quantity, item.product_id]
                );

                if (stockUpdateResult.rows.length === 0) {
                    // This shouldn't happen due to validation, but safety check
                    throw new Error(`Failed to update stock for product #${item.product_id}`);
                }

                const updatedProduct = stockUpdateResult.rows[0];
                console.log(`📉 Stock updated for "${updatedProduct.name}": ${updatedProduct.quantity_in_stock} units remaining`);
            }
        }

        await client.query('COMMIT');
        console.log(`✅ Order #${order.id} completed successfully`);

        res.status(201).json({
            success: true,
            message: 'Order created successfully',
            data: order
        });
    } catch (error) {
        await client.query('ROLLBACK');
        console.error('❌ Error creating order:', error);
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

    // Validate status value
    const validStatuses = ['pending', 'confirmed', 'assigned', 'in_transit', 'delivered', 'cancelled'];
    if (!validStatuses.includes(status)) {
        console.error(`❌ Invalid status attempted: "${status}". Valid statuses: ${validStatuses.join(', ')}`);
        return res.status(400).json({
            success: false,
            message: `Invalid status value. Must be one of: ${validStatuses.join(', ')}`,
            validStatuses: validStatuses
        });
    }

    const client = await pool.connect();

    try {
        await client.query('BEGIN');

        console.log(`📝 Updating order #${id} status to: ${status}`);

        // Get current order status and items
        const orderCheck = await client.query(
            `SELECT id, status, user_id FROM orders WHERE id = $1`,
            [id]
        );

        if (orderCheck.rows.length === 0) {
            await client.query('ROLLBACK');
            console.error(`❌ Order #${id} not found for status update`);
            return res.status(404).json({
                success: false,
                message: 'Order not found'
            });
        }

        const currentOrder = orderCheck.rows[0];
        const previousStatus = currentOrder.status;

        // STATUS WORKFLOW VALIDATION: Prevent invalid status transitions
        const statusHierarchy = {
            'pending': 1,
            'confirmed': 2,
            'assigned': 3,
            'in_transit': 4,
            'delivered': 5,
            'cancelled': 99 // Can transition to cancelled from any status
        };

        // Allow cancelled from any status, or forward progression only
        if (status !== 'cancelled') {
            const currentLevel = statusHierarchy[previousStatus] || 0;
            const newLevel = statusHierarchy[status] || 0;
            
            // Prevent backwards status changes (e.g., delivered → in_transit)
            if (newLevel < currentLevel) {
                await client.query('ROLLBACK');
                console.error(`❌ Invalid status transition: ${previousStatus} → ${status}`);
                return res.status(400).json({
                    success: false,
                    message: `Invalid status transition. Cannot change from '${previousStatus}' to '${status}'. Status can only move forward in the workflow.`,
                    currentStatus: previousStatus,
                    attemptedStatus: status
                });
            }
        }

        // STOCK RESTORATION: If changing to 'cancelled' from a non-cancelled status
        if (status === 'cancelled' && previousStatus !== 'cancelled') {
            console.log(`🔄 Order being cancelled - restoring stock...`);

            // Get all order items
            const orderItems = await client.query(
                `SELECT oi.product_id, oi.quantity, p.name 
                 FROM order_items oi
                 JOIN products p ON oi.product_id = p.id
                 WHERE oi.order_id = $1`,
                [id]
            );

            // Restore stock for each item
            for (const item of orderItems.rows) {
                const restoreResult = await client.query(
                    `UPDATE products 
                     SET quantity_in_stock = quantity_in_stock + $1,
                         updated_at = CURRENT_TIMESTAMP
                     WHERE id = $2
                     RETURNING id, name, quantity_in_stock`,
                    [item.quantity, item.product_id]
                );

                if (restoreResult.rows.length > 0) {
                    const restoredProduct = restoreResult.rows[0];
                    console.log(`📈 Stock restored for "${restoredProduct.name}": +${item.quantity} units (now ${restoredProduct.quantity_in_stock})`);
                }
            }

            console.log(`✅ Stock restoration completed for order #${id}`);
        }

        // Update the order status
        const result = await client.query(
            `UPDATE orders 
             SET status = $1, tracking_number = $2, updated_at = CURRENT_TIMESTAMP
             WHERE id = $3
             RETURNING *`,
            [status, tracking_number, id]
        );

        await client.query('COMMIT');

        console.log(`✅ Order #${id} status updated: ${previousStatus} → ${status}`);
        res.json({
            success: true,
            message: 'Order status updated successfully',
            data: result.rows[0],
            stock_restored: status === 'cancelled' && previousStatus !== 'cancelled'
        });
    } catch (error) {
        await client.query('ROLLBACK');
        console.error(`❌ Error updating order #${id} status:`, error);

        // Check for constraint violation
        if (error.code === '23514') { // PostgreSQL CHECK constraint violation
            return res.status(400).json({
                success: false,
                message: `Invalid status value. Must be one of: ${validStatuses.join(', ')}`,
                error: 'Status constraint violation',
                validStatuses: validStatuses
            });
        }

        // Generic error
        return res.status(500).json({
            success: false,
            message: 'Failed to update order status',
            error: error.message
        });
    } finally {
        client.release();
    }
};

// @desc    Delete order
// @route   DELETE /api/orders/:id
// @access  Private/Admin
const deleteOrder = async (req, res) => {
    const { id } = req.params;
    const client = await pool.connect();

    try {
        await client.query('BEGIN');
        console.log(`🗑️  Deleting order #${id}...`);

        // Get order details before deletion
        const orderCheck = await client.query(
            `SELECT id, status FROM orders WHERE id = $1`,
            [id]
        );

        if (orderCheck.rows.length === 0) {
            await client.query('ROLLBACK');
            return res.status(404).json({
                success: false,
                message: 'Order not found'
            });
        }

        const order = orderCheck.rows[0];

        // If order is not cancelled, restore stock before deletion
        if (order.status !== 'cancelled') {
            console.log(`🔄 Restoring stock before order deletion...`);

            // Get all order items
            const orderItems = await client.query(
                `SELECT oi.product_id, oi.quantity, p.name 
                 FROM order_items oi
                 JOIN products p ON oi.product_id = p.id
                 WHERE oi.order_id = $1`,
                [id]
            );

            // Restore stock for each item
            for (const item of orderItems.rows) {
                await client.query(
                    `UPDATE products 
                     SET quantity_in_stock = quantity_in_stock + $1,
                         updated_at = CURRENT_TIMESTAMP
                     WHERE id = $2`,
                    [item.quantity, item.product_id]
                );
                console.log(`📈 Stock restored for "${item.name}": +${item.quantity} units`);
            }
        }

        // Delete the order (cascade will delete order_items)
        const result = await client.query('DELETE FROM orders WHERE id = $1 RETURNING id', [id]);

        await client.query('COMMIT');
        console.log(`✅ Order #${id} deleted successfully`);

        res.json({
            success: true,
            message: 'Order deleted successfully',
            stock_restored: order.status !== 'cancelled'
        });
    } catch (error) {
        await client.query('ROLLBACK');
        console.error(`❌ Error deleting order #${id}:`, error);
        res.status(500).json({
            success: false,
            message: 'Failed to delete order',
            error: error.message
        });
    } finally {
        client.release();
    }
};

// ========== MANAGER FUNCTIONS ==========

// @desc    Get all confirmed unassigned orders (for manager to assign)
// @route   GET /api/orders/manager/pending
// @access  Private/Manager
const getPendingOrders = async (req, res) => {
    try {
        // Only return CONFIRMED orders that are NOT yet assigned
        // Pending orders need admin approval first
        const result = await pool.query(
            `SELECT o.* FROM orders o
             WHERE o.status = 'confirmed' AND o.delivery_man_id IS NULL
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

// ========== INVENTORY MONITORING ==========

// @desc    Get products with low stock (for inventory management)
// @route   GET /api/orders/inventory/low-stock
// @access  Private/Admin
const getLowStockProducts = async (req, res) => {
    try {
        const threshold = parseInt(req.query.threshold) || 10; // Default threshold: 10 units

        console.log(`📊 Checking for products with stock below ${threshold} units...`);

        const result = await pool.query(
            `SELECT 
                id,
                name,
                type,
                quantity_in_stock,
                price,
                image_url,
                CASE 
                    WHEN quantity_in_stock = 0 THEN 'out_of_stock'
                    WHEN quantity_in_stock < 5 THEN 'critical'
                    WHEN quantity_in_stock < 10 THEN 'low'
                    ELSE 'warning'
                END as stock_level
             FROM products 
             WHERE quantity_in_stock < $1
             ORDER BY quantity_in_stock ASC, name ASC`,
            [threshold]
        );

        // Categorize products by stock level
        const stockReport = {
            out_of_stock: result.rows.filter(p => p.quantity_in_stock === 0),
            critical: result.rows.filter(p => p.quantity_in_stock > 0 && p.quantity_in_stock < 5),
            low: result.rows.filter(p => p.quantity_in_stock >= 5 && p.quantity_in_stock < 10),
            warning: result.rows.filter(p => p.quantity_in_stock >= 10 && p.quantity_in_stock < threshold)
        };

        const summary = {
            total_low_stock_products: result.rows.length,
            out_of_stock_count: stockReport.out_of_stock.length,
            critical_count: stockReport.critical.length,
            low_count: stockReport.low.length,
            warning_count: stockReport.warning.length,
            threshold: threshold
        };

        console.log(`📋 Low stock summary:`, summary);

        res.json({
            success: true,
            summary: summary,
            products: stockReport,
            all_products: result.rows
        });
    } catch (error) {
        console.error('❌ Error fetching low stock products:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to fetch low stock products',
            error: error.message
        });
    }
};

module.exports = {
    getAllOrders,
    getMyOrders,
    getOrderById,
    getOrderItems,
    createOrder,
    updateOrderStatus,
    deleteOrder,
    // Manager functions
    getPendingOrders,
    getDeliveryMen,
    assignOrderToDelivery,
    getDeliveryManOrders,
    unassignOrderFromDelivery,
    // Delivery functions
    getMyDeliveries,
    // Inventory monitoring
    getLowStockProducts
};

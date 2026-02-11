const pool = require('../db/connection');

// @desc    Get all addresses for current user
// @route   GET /api/addresses
// @access  Private
const getUserAddresses = async (req, res) => {
    try {
        const result = await pool.query(
            'SELECT * FROM addresses WHERE user_id = $1 ORDER BY is_default DESC, created_at DESC',
            [req.user.id]
        );

        res.json({
            success: true,
            data: result.rows,
            count: result.rowCount
        });
    } catch (error) {
        console.error('Error fetching addresses:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to fetch addresses',
            error: error.message
        });
    }
};

// @desc    Get single address by ID
// @route   GET /api/addresses/:id
// @access  Private
const getAddressById = async (req, res) => {
    try {
        const { id } = req.params;
        const result = await pool.query(
            'SELECT * FROM addresses WHERE id = $1',
            [id]
        );

        if (result.rowCount === 0) {
            return res.status(404).json({
                success: false,
                message: 'Address not found'
            });
        }

        const address = result.rows[0];

        // Check if user owns this address, is admin, or is delivery person with assigned order
        let isAuthorized = address.user_id === req.user.id ||
            req.user.role === 'admin' ||
            req.user.role === 'manager';

        // Additional check for delivery_man: allow if they have an order assigned with this address
        if (!isAuthorized && req.user.role === 'delivery_man') {
            const orderCheck = await pool.query(
                `SELECT id FROM orders 
                 WHERE delivery_man_id = $1 
                 AND (shipping_address_id = $2 OR billing_address_id = $2)`,
                [req.user.id, id]
            );
            isAuthorized = orderCheck.rowCount > 0;
        }

        if (!isAuthorized) {
            return res.status(403).json({
                success: false,
                message: 'Not authorized to view this address'
            });
        }

        res.json({
            success: true,
            data: address
        });
    } catch (error) {
        console.error('Error fetching address:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to fetch address',
            error: error.message
        });
    }
};

// @desc    Get user's default address
// @route   GET /api/addresses/default
// @access  Private
const getDefaultAddress = async (req, res) => {
    try {
        const result = await pool.query(
            'SELECT * FROM addresses WHERE user_id = $1 AND is_default = true LIMIT 1',
            [req.user.id]
        );

        if (result.rowCount === 0) {
            return res.status(404).json({
                success: false,
                message: 'No default address found'
            });
        }

        res.json({
            success: true,
            data: result.rows[0]
        });
    } catch (error) {
        console.error('Error fetching default address:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to fetch default address',
            error: error.message
        });
    }
};

// @desc    Create new address
// @route   POST /api/addresses
// @access  Private
const createAddress = async (req, res) => {
    try {
        const {
            address_type,
            street_address,
            city,
            country,
            is_default
        } = req.body;

        // If this is set as default, unset other default addresses
        if (is_default) {
            await pool.query(
                'UPDATE addresses SET is_default = false WHERE user_id = $1',
                [req.user.id]
            );
        }

        // Create new address
        const result = await pool.query(
            `INSERT INTO addresses (user_id, address_type, street_address, city, country, is_default)
             VALUES ($1, $2, $3, $4, $5, $6)
             RETURNING *`,
            [req.user.id, address_type, street_address, city, country, is_default || false]
        );

        console.log('✅ Address created:', result.rows[0].id);

        res.status(201).json({
            success: true,
            message: 'Address created successfully',
            data: result.rows[0]
        });
    } catch (error) {
        console.error('Error creating address:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to create address',
            error: error.message
        });
    }
};

// @desc    Update address
// @route   PUT /api/addresses/:id
// @access  Private
const updateAddress = async (req, res) => {
    try {
        const { id } = req.params;
        const {
            address_type,
            street_address,
            city,
            country,
            is_default
        } = req.body;

        // Check if address exists and user owns it
        const checkAddress = await pool.query(
            'SELECT * FROM addresses WHERE id = $1',
            [id]
        );

        if (checkAddress.rowCount === 0) {
            return res.status(404).json({
                success: false,
                message: 'Address not found'
            });
        }

        const address = checkAddress.rows[0];

        if (address.user_id !== req.user.id && req.user.role !== 'admin') {
            return res.status(403).json({
                success: false,
                message: 'Not authorized to update this address'
            });
        }

        // If this is set as default, unset other default addresses
        if (is_default) {
            await pool.query(
                'UPDATE addresses SET is_default = false WHERE user_id = $1 AND id != $2',
                [address.user_id, id]
            );
        }

        // Update address
        const result = await pool.query(
            `UPDATE addresses 
             SET address_type = $1, street_address = $2, city = $3, country = $4, 
                 is_default = $5, updated_at = CURRENT_TIMESTAMP
             WHERE id = $6
             RETURNING *`,
            [address_type, street_address, city, country, is_default || false, id]
        );

        console.log('✅ Address updated:', id);

        res.json({
            success: true,
            message: 'Address updated successfully',
            data: result.rows[0]
        });
    } catch (error) {
        console.error('Error updating address:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to update address',
            error: error.message
        });
    }
};

// @desc    Set address as default
// @route   PUT /api/addresses/:id/set-default
// @access  Private
const setDefaultAddress = async (req, res) => {
    try {
        const { id } = req.params;

        // Check if address exists and user owns it
        const checkAddress = await pool.query(
            'SELECT * FROM addresses WHERE id = $1',
            [id]
        );

        if (checkAddress.rowCount === 0) {
            return res.status(404).json({
                success: false,
                message: 'Address not found'
            });
        }

        const address = checkAddress.rows[0];

        if (address.user_id !== req.user.id && req.user.role !== 'admin') {
            return res.status(403).json({
                success: false,
                message: 'Not authorized to update this address'
            });
        }

        // Unset all default addresses for this user
        await pool.query(
            'UPDATE addresses SET is_default = false WHERE user_id = $1',
            [address.user_id]
        );

        // Set this address as default
        const result = await pool.query(
            `UPDATE addresses 
             SET is_default = true, updated_at = CURRENT_TIMESTAMP
             WHERE id = $1
             RETURNING *`,
            [id]
        );

        console.log('✅ Default address set:', id);

        res.json({
            success: true,
            message: 'Default address updated',
            data: result.rows[0]
        });
    } catch (error) {
        console.error('Error setting default address:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to set default address',
            error: error.message
        });
    }
};

// @desc    Delete address
// @route   DELETE /api/addresses/:id
// @access  Private
const deleteAddress = async (req, res) => {
    try {
        const { id } = req.params;

        // Check if address exists and user owns it
        const checkAddress = await pool.query(
            'SELECT * FROM addresses WHERE id = $1',
            [id]
        );

        if (checkAddress.rowCount === 0) {
            return res.status(404).json({
                success: false,
                message: 'Address not found'
            });
        }

        const address = checkAddress.rows[0];

        if (address.user_id !== req.user.id && req.user.role !== 'admin') {
            return res.status(403).json({
                success: false,
                message: 'Not authorized to delete this address'
            });
        }

        // Check if address is used in any orders
        const ordersUsingAddress = await pool.query(
            'SELECT COUNT(*) as count FROM orders WHERE shipping_address_id = $1',
            [id]
        );

        if (parseInt(ordersUsingAddress.rows[0].count) > 0) {
            return res.status(400).json({
                success: false,
                message: 'This address cannot be deleted because it is used in your order history'
            });
        }

        // Delete address
        await pool.query('DELETE FROM addresses WHERE id = $1', [id]);

        console.log('✅ Address deleted:', id);

        res.json({
            success: true,
            message: 'Address deleted successfully'
        });
    } catch (error) {
        console.error('Error deleting address:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to delete address',
            error: error.message
        });
    }
};

// @desc    Get addresses by user ID (Admin only)
// @route   GET /api/addresses/user/:userId
// @access  Private/Admin
const getAddressesByUserId = async (req, res) => {
    try {
        const { userId } = req.params;

        const result = await pool.query(
            'SELECT * FROM addresses WHERE user_id = $1 ORDER BY is_default DESC, created_at DESC',
            [userId]
        );

        res.json({
            success: true,
            data: result.rows,
            count: result.rowCount
        });
    } catch (error) {
        console.error('Error fetching user addresses:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to fetch user addresses',
            error: error.message
        });
    }
};

module.exports = {
    getUserAddresses,
    getAddressById,
    getDefaultAddress,
    createAddress,
    updateAddress,
    setDefaultAddress,
    deleteAddress,
    getAddressesByUserId
};

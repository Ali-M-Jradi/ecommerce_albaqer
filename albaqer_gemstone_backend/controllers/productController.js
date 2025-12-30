const pool = require('../db/connection');

// @desc    Get all products
// @route   GET /api/products
// @access  Public
const getAllProducts = async (req, res) => {
    const result = await pool.query(
        'SELECT * FROM products WHERE is_available = true ORDER BY created_at DESC'
    );

    res.json({
        success: true,
        data: result.rows,
        count: result.rowCount
    });
};

// @desc    Get single product by ID
// @route   GET /api/products/:id
// @access  Public
const getProductById = async (req, res) => {
    const { id } = req.params;
    const result = await pool.query('SELECT * FROM products WHERE id = $1', [id]);

    if (result.rowCount === 0) {
        return res.status(404).json({
            success: false,
            message: 'Product not found'
        });
    }

    res.json({
        success: true,
        data: result.rows[0]
    });
};

// @desc    Create new product
// @route   POST /api/products
// @access  Private/Admin
const createProduct = async (req, res) => {
    const { name, type, description, base_price, quantity_in_stock, image_url } = req.body;

    const result = await pool.query(
        `INSERT INTO products (name, type, description, base_price, quantity_in_stock, image_url)
         VALUES ($1, $2, $3, $4, $5, $6)
         RETURNING *`,
        [name, type, description, base_price, quantity_in_stock, image_url]
    );

    res.status(201).json({
        success: true,
        message: 'Product created successfully',
        data: result.rows[0]
    });
};

// @desc    Update product
// @route   PUT /api/products/:id
// @access  Private/Admin
const updateProduct = async (req, res) => {
    const { id } = req.params;
    const { name, type, description, base_price, quantity_in_stock, image_url, is_available } = req.body;

    const result = await pool.query(
        `UPDATE products 
         SET name = $1, type = $2, description = $3, base_price = $4, 
             quantity_in_stock = $5, image_url = $6, is_available = $7, updated_at = CURRENT_TIMESTAMP
         WHERE id = $8
         RETURNING *`,
        [name, type, description, base_price, quantity_in_stock, image_url, is_available, id]
    );

    if (result.rowCount === 0) {
        return res.status(404).json({
            success: false,
            message: 'Product not found'
        });
    }

    res.json({
        success: true,
        message: 'Product updated successfully',
        data: result.rows[0]
    });
};

// @desc    Delete product
// @route   DELETE /api/products/:id
// @access  Private/Admin
const deleteProduct = async (req, res) => {
    const { id } = req.params;
    const result = await pool.query('DELETE FROM products WHERE id = $1 RETURNING id', [id]);

    if (result.rowCount === 0) {
        return res.status(404).json({
            success: false,
            message: 'Product not found'
        });
    }

    res.json({
        success: true,
        message: 'Product deleted successfully'
    });
};

// @desc    Get all unique product categories
// @route   GET /api/products/categories
// @access  Public
const getProductCategories = async (req, res) => {
    const result = await pool.query(
        'SELECT DISTINCT type FROM products WHERE type IS NOT NULL ORDER BY type'
    );

    res.json({
        success: true,
        data: result.rows.map(row => row.type)
    });
};

// @desc    Search products
// @route   GET /api/products/search
// @access  Public
const searchProducts = async (req, res) => {
    const { query, type, minPrice, maxPrice } = req.query;

    let sqlQuery = 'SELECT * FROM products WHERE is_available = true';
    const params = [];
    let paramCount = 1;

    if (query) {
        sqlQuery += ` AND (name ILIKE $${paramCount} OR description ILIKE $${paramCount})`;
        params.push(`%${query}%`);
        paramCount++;
    }

    if (type) {
        sqlQuery += ` AND type = $${paramCount}`;
        params.push(type);
        paramCount++;
    }

    if (minPrice) {
        sqlQuery += ` AND base_price >= $${paramCount}`;
        params.push(minPrice);
        paramCount++;
    }

    if (maxPrice) {
        sqlQuery += ` AND base_price <= $${paramCount}`;
        params.push(maxPrice);
        paramCount++;
    }

    sqlQuery += ' ORDER BY created_at DESC';

    const result = await pool.query(sqlQuery, params);

    res.json({
        success: true,
        data: result.rows,
        count: result.rowCount
    });
};

module.exports = {
    getAllProducts,
    getProductById,
    createProduct,
    updateProduct,
    deleteProduct,
    searchProducts,
    getProductCategories
};

const pool = require('../db/connection');

// @desc    Get all products with advanced filtering
// @route   GET /api/products
// @access  Public
const getAllProducts = async (req, res) => {
    try {
        const {
            minPrice,
            maxPrice,
            category,
            gemstoneType,
            gender,
            color,
            metalType,
            inStock,
            islamicTag,
            minRating,
            size,
            sortBy = 'created_at',
            sortOrder = 'DESC',
            search
        } = req.query;

        console.log('📥 Filter params received:', { category, minPrice, maxPrice, gemstoneType, gender });

        let query = 'SELECT * FROM products WHERE is_available = true';
        const values = [];
        let paramCount = 1;

        // Price range filter
        if (minPrice) {
            query += ` AND base_price >= $${paramCount++}`;
            values.push(parseFloat(minPrice));
        }
        if (maxPrice) {
            query += ` AND base_price <= $${paramCount++}`;
            values.push(parseFloat(maxPrice));
        }

        // Category filter (ring, necklace, bracelet, etc.)
        if (category) {
            query += ` AND category = $${paramCount++}`;
            values.push(category.toLowerCase());
        }

        // Gemstone type filter (uses stone_type column)
        if (gemstoneType) {
            query += ` AND stone_type ILIKE $${paramCount++}`;
            values.push(`%${gemstoneType}%`);
        }

        // Gender filter (include unisex in results)
        if (gender && gender !== 'unisex') {
            query += ` AND (gender = $${paramCount} OR gender = 'unisex')`;
            values.push(gender.toLowerCase());
            paramCount++;
        }

        // Color filter (uses stone_color column)
        if (color) {
            query += ` AND stone_color ILIKE $${paramCount++}`;
            values.push(`%${color}%`);
        }

        // Metal type filter
        if (metalType) {
            query += ` AND metal_type ILIKE $${paramCount++}`;
            values.push(`%${metalType}%`);
        }

        // In stock filter
        if (inStock === 'true') {
            query += ' AND quantity_in_stock > 0';
        }

        // Islamic significance filter
        if (islamicTag) {
            query += ` AND islamic_tags ILIKE $${paramCount++}`;
            values.push(`%${islamicTag}%`);
        }

        // Rating filter
        if (minRating) {
            query += ` AND average_rating >= $${paramCount++}`;
            values.push(parseFloat(minRating));
        }

        // Size filter
        if (size) {
            query += ` AND available_sizes ILIKE $${paramCount++}`;
            values.push(`%${size}%`);
        }

        // Search filter (searches in name, description, type)
        if (search) {
            query += ` AND (name ILIKE $${paramCount} OR description ILIKE $${paramCount} OR type ILIKE $${paramCount})`;
            values.push(`%${search}%`);
            paramCount++;
        }

        // Validate and sanitize sort column
        const allowedSortColumns = [
            'created_at', 'base_price', 'average_rating',
            'name', 'quantity_in_stock', 'review_count'
        ];
        const sortColumn = allowedSortColumns.includes(sortBy) ? sortBy : 'created_at';
        const order = sortOrder.toUpperCase() === 'ASC' ? 'ASC' : 'DESC';

        query += ` ORDER BY ${sortColumn} ${order}`;

        console.log('🔍 SQL Query:', query);
        console.log('🔍 SQL Values:', values);

        const result = await pool.query(query, values);

        res.json({
            success: true,
            data: result.rows,
            count: result.rowCount,
            filters: {
                minPrice,
                maxPrice,
                category,
                gemstoneType,
                gender,
                color,
                metalType,
                inStock,
                islamicTag,
                minRating,
                size,
                sortBy: sortColumn,
                sortOrder: order,
                search
            }
        });
    } catch (error) {
        console.error('❌ Error fetching products:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to fetch products',
            error: error.message
        });
    }
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

// @desc    Get available filter options
// @route   GET /api/products/filters/options
// @access  Public
const getFilterOptions = async (req, res) => {
    try {
        // Get distinct values for each filter
        const result = await pool.query(`
            SELECT 
                json_build_object(
                    'categories', (
                        SELECT json_agg(DISTINCT category) 
                        FROM products 
                        WHERE category IS NOT NULL AND is_available = true
                    ),
                    'gemstoneTypes', (
                        SELECT json_agg(DISTINCT stone_type) 
                        FROM products 
                        WHERE stone_type IS NOT NULL AND is_available = true
                    ),
                    'colors', (
                        SELECT json_agg(DISTINCT stone_color) 
                        FROM products 
                        WHERE stone_color IS NOT NULL AND is_available = true
                    ),
                    'metalTypes', (
                        SELECT json_agg(DISTINCT metal_type) 
                        FROM products 
                        WHERE metal_type IS NOT NULL AND is_available = true
                    ),
                    'genders', (
                        SELECT json_agg(DISTINCT gender) 
                        FROM products 
                        WHERE gender IS NOT NULL AND is_available = true
                    ),
                    'priceRange', (
                        SELECT json_build_object(
                            'min', COALESCE(MIN(base_price), 0),
                            'max', COALESCE(MAX(base_price), 10000)
                        )
                        FROM products
                        WHERE is_available = true
                    ),
                    'islamicTags', ARRAY['sunnah', 'protection', 'healing', 'success', 'prosperity', 'imam_ali', 'spiritual']
                ) as filter_options
        `);

        res.json({
            success: true,
            data: result.rows[0].filter_options
        });
    } catch (error) {
        console.error('❌ Error fetching filter options:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to fetch filter options',
            error: error.message
        });
    }
};

module.exports = {
    getAllProducts,
    getProductById,
    createProduct,
    updateProduct,
    deleteProduct,
    searchProducts,
    getProductCategories,
    getFilterOptions
};

const pool = require('../db/connection');
const bcrypt = require('bcryptjs');
const { generateToken } = require('../middleware/auth');

// @desc    Register new user
// @route   POST /api/users/register
// @access  Public
const registerUser = async (req, res) => {
    try {
        const { email, password, full_name, phone } = req.body;
        console.log('📝 Registration attempt:', { email, full_name, phone });

        // Validate required fields
        if (!email || !password || !full_name) {
            return res.status(400).json({
                success: false,
                message: 'Email, password, and full name are required'
            });
        }

        // Check if user already exists
        const checkUser = await pool.query('SELECT * FROM users WHERE email = $1', [email]);

        if (checkUser.rowCount > 0) {
            return res.status(400).json({
                success: false,
                message: 'User already exists'
            });
        }

        // Hash password
        const salt = await bcrypt.genSalt(10);
        const password_hash = await bcrypt.hash(password, salt);

        // Create user
        const result = await pool.query(
            `INSERT INTO users (email, password_hash, full_name, phone)
             VALUES ($1, $2, $3, $4)
             RETURNING id, email, full_name, phone, created_at`,
            [email, password_hash, full_name, phone]
        );

        const user = result.rows[0];
        console.log('✅ User registered successfully:', user.id);

        res.status(201).json({
            success: true,
            message: 'User registered successfully',
            data: {
                id: user.id,
                email: user.email,
                full_name: user.full_name,
                phone: user.phone,
                token: generateToken(user.id, user.email, 'customer')
            }
        });
    } catch (error) {
        console.error('❌ Registration error:', error);
        res.status(500).json({
            success: false,
            message: 'Server error during registration',
            error: error.message
        });
    }
};

// @desc    Login user
// @route   POST /api/users/login
// @access  Public
const loginUser = async (req, res) => {
    try {
        const { email, password } = req.body;
        console.log('🔐 Login attempt:', { email });

        // Validate required fields
        if (!email || !password) {
            return res.status(400).json({
                success: false,
                message: 'Email and password are required'
            });
        }

        // Check if user exists
        const result = await pool.query('SELECT * FROM users WHERE email = $1', [email]);
        console.log('👤 User query result:', { found: result.rowCount > 0 });

        if (result.rowCount === 0) {
            return res.status(401).json({
                success: false,
                message: 'Invalid credentials'
            });
        }

        const user = result.rows[0];
        console.log('👤 User found:', { id: user.id, email: user.email, is_active: user.is_active });

        // Check if user is active
        if (!user.is_active) {
            return res.status(403).json({
                success: false,
                message: 'Account is inactive'
            });
        }

        // Compare password
        console.log('🔑 Comparing password...');
        const isMatch = await bcrypt.compare(password, user.password_hash);
        console.log('🔑 Password match:', isMatch);

        if (!isMatch) {
            return res.status(401).json({
                success: false,
                message: 'Invalid credentials'
            });
        }

        console.log('✅ Login successful:', user.id);
        res.json({
            success: true,
            message: 'Login successful',
            data: {
                id: user.id,
                email: user.email,
                full_name: user.full_name,
                phone: user.phone,
                token: generateToken(user.id, user.email, user.role || 'customer')
            }
        });
    } catch (error) {
        console.error('❌ Login error:', error);
        res.status(500).json({
            success: false,
            message: 'Server error during login',
            error: error.message
        });
    }
};

// @desc    Get user profile
// @route   GET /api/users/profile
// @access  Private
const getUserProfile = async (req, res) => {
    const result = await pool.query(
        'SELECT id, email, full_name, phone, is_active, created_at FROM users WHERE id = $1',
        [req.user.id]
    );

    if (result.rowCount === 0) {
        return res.status(404).json({
            success: false,
            message: 'User not found'
        });
    }

    res.json({
        success: true,
        data: result.rows[0]
    });
};

// @desc    Update user profile
// @route   PUT /api/users/profile
// @access  Private
const updateUserProfile = async (req, res) => {
    const { full_name, phone } = req.body;

    const result = await pool.query(
        `UPDATE users 
         SET full_name = $1, phone = $2, updated_at = CURRENT_TIMESTAMP
         WHERE id = $3
         RETURNING id, email, full_name, phone`,
        [full_name, phone, req.user.id]
    );

    res.json({
        success: true,
        message: 'Profile updated successfully',
        data: result.rows[0]
    });
};

// @desc    Get all users
// @route   GET /api/users
// @access  Private/Admin
const getAllUsers = async (req, res) => {
    const result = await pool.query(
        'SELECT id, email, full_name, phone, is_active, created_at FROM users ORDER BY created_at DESC'
    );

    res.json({
        success: true,
        data: result.rows,
        count: result.rowCount
    });
};

module.exports = {
    registerUser,
    loginUser,
    getUserProfile,
    updateUserProfile,
    getAllUsers
};

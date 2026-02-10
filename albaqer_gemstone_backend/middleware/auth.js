const jwt = require('jsonwebtoken');

// Protect routes - verify JWT token
const protect = async (req, res, next) => {
    let token;

    // Check for token in headers
    if (req.headers.authorization && req.headers.authorization.startsWith('Bearer')) {
        try {
            // Get token from header
            token = req.headers.authorization.split(' ')[1];

            // Verify token
            const decoded = jwt.verify(token, process.env.JWT_SECRET || 'your-secret-key');

            // Attach user info to request
            req.user = {
                id: decoded.id,
                email: decoded.email,
                role: decoded.role
            };

            next();
        } catch (error) {
            console.error('Token verification failed:', error);
            return res.status(401).json({
                success: false,
                message: 'Not authorized, token failed'
            });
        }
    }

    if (!token) {
        return res.status(401).json({
            success: false,
            message: 'Not authorized, no token'
        });
    }
};

// Admin only access
const admin = (req, res, next) => {
    if (req.user && req.user.role === 'admin') {
        next();
    } else {
        res.status(403).json({
            success: false,
            message: 'Not authorized as admin'
        });
    }
};

// Manager only access
const manager = (req, res, next) => {
    if (req.user && req.user.role === 'manager') {
        next();
    } else {
        res.status(403).json({
            success: false,
            message: 'Not authorized as manager'
        });
    }
};

// Delivery man only access
const deliveryMan = (req, res, next) => {
    if (req.user && req.user.role === 'delivery_man') {
        next();
    } else {
        res.status(403).json({
            success: false,
            message: 'Not authorized as delivery man'
        });
    }
};

// Manager or Admin access
const managerOrAdmin = (req, res, next) => {
    if (req.user && (req.user.role === 'manager' || req.user.role === 'admin')) {
        next();
    } else {
        res.status(403).json({
            success: false,
            message: 'Not authorized. Manager or Admin access required'
        });
    }
};

// Generate JWT token
const generateToken = (id, email, role = 'customer') => {
    return jwt.sign(
        { id, email, role },
        process.env.JWT_SECRET || 'your-secret-key',
        { expiresIn: '30d' }
    );
};

module.exports = {
    protect,
    admin,
    manager,
    deliveryMan,
    managerOrAdmin,
    generateToken
};

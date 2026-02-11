const { body, param, validationResult } = require('express-validator');

// Validation result checker
const validate = (req, res, next) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
        return res.status(400).json({
            success: false,
            message: 'Validation failed',
            errors: errors.array()
        });
    }
    next();
};

// Product validation rules
const validateProduct = [
    body('name')
        .trim()
        .notEmpty().withMessage('Product name is required')
        .isLength({ min: 3, max: 255 }).withMessage('Name must be between 3 and 255 characters'),
    body('type')
        .trim()
        .notEmpty().withMessage('Product type is required')
        .isIn(['ring', 'necklace', 'bracelet', 'earring', 'pendant', 'other'])
        .withMessage('Invalid product type'),
    body('description')
        .optional()
        .trim()
        .isLength({ max: 1000 }).withMessage('Description cannot exceed 1000 characters'),
    body('base_price')
        .notEmpty().withMessage('Price is required')
        .isFloat({ min: 0 }).withMessage('Price must be a positive number'),
    body('quantity_in_stock')
        .notEmpty().withMessage('Quantity is required')
        .isInt({ min: 0 }).withMessage('Quantity must be a non-negative integer'),
    body('image_url')
        .optional()
        .trim()
        .isURL().withMessage('Invalid image URL'),
    validate
];

// User registration validation rules
const validateUserRegister = [
    body('email')
        .trim()
        .notEmpty().withMessage('Email is required')
        .isEmail().withMessage('Invalid email format')
        .normalizeEmail(),
    body('password')
        .notEmpty().withMessage('Password is required')
        .isLength({ min: 6 }).withMessage('Password must be at least 6 characters'),
    body('full_name')
        .trim()
        .notEmpty().withMessage('Full name is required')
        .isLength({ min: 2, max: 100 }).withMessage('Name must be between 2 and 100 characters'),
    body('phone')
        .optional({ nullable: true, checkFalsy: true })
        .trim()
        .isLength({ min: 8, max: 20 }).withMessage('Phone number must be 8-20 characters'),
    validate
];

// User login validation rules
const validateUserLogin = [
    body('email')
        .trim()
        .notEmpty().withMessage('Email is required')
        .isEmail().withMessage('Invalid email format'),
    body('password')
        .notEmpty().withMessage('Password is required'),
    validate
];

// Order validation rules
const validateOrder = [
    body('user_id')
        .notEmpty().withMessage('User ID is required')
        .isInt().withMessage('User ID must be an integer'),
    body('total_amount')
        .notEmpty().withMessage('Total amount is required')
        .isFloat({ min: 0 }).withMessage('Total amount must be a positive number'),
    body('status')
        .optional()
        .isIn(['pending', 'processing', 'shipped', 'delivered', 'cancelled'])
        .withMessage('Invalid order status'),
    validate
];

// Address validation rules
const validateAddress = [
    body('address_type')
        .trim()
        .notEmpty().withMessage('Address type is required')
        .isIn(['shipping', 'billing', 'both'])
        .withMessage('Address type must be shipping, billing, or both'),
    body('street_address')
        .trim()
        .notEmpty().withMessage('Street address is required')
        .isLength({ min: 5, max: 500 }).withMessage('Street address must be between 5 and 500 characters'),
    body('city')
        .trim()
        .notEmpty().withMessage('City is required')
        .isLength({ min: 2, max: 100 }).withMessage('City must be between 2 and 100 characters'),
    body('country')
        .trim()
        .notEmpty().withMessage('Country is required')
        .isLength({ min: 2, max: 100 }).withMessage('Country must be between 2 and 100 characters'),
    body('is_default')
        .optional()
        .isBoolean().withMessage('is_default must be a boolean'),
    validate
];

// ID parameter validation
const validateId = [
    param('id')
        .isInt({ min: 1 }).withMessage('Invalid ID parameter'),
    validate
];

module.exports = {
    validateProduct,
    validateUserRegister,
    validateUserLogin,
    validateOrder,
    validateAddress,
    validateId
};

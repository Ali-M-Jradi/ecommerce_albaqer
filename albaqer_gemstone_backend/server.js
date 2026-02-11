const express = require('express');
const cors = require('cors');
const dotenv = require('dotenv');
const path = require('path');
const pool = require('./db/connection');
const { errorHandler, notFound } = require('./middleware/errorHandler');

// Load environment variables
dotenv.config();

const app = express();
const PORT = process.env.PORT || 3000;

// ⚙️ CONFIGURATION - Server IP (must match Flutter api_config.dart)
const SERVER_IP = '192.168.0.106';  // ✅ Your real Wi-Fi network

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Serve static files (product images)
app.use('/images', express.static(path.join(__dirname, 'public/images')));

// Request logging
app.use((req, res, next) => {
    console.log(`📨 ${new Date().toISOString()} - ${req.method} ${req.url}`);

    // Log response
    const originalSend = res.send;
    res.send = function (data) {
        console.log(`📤 ${new Date().toISOString()} - Response sent: ${res.statusCode}`);
        originalSend.call(this, data);
    };

    next();
});

// Test database connection endpoint
app.get('/api/test-db', async (req, res) => {
    try {
        const result = await pool.query('SELECT NOW()');
        res.json({
            success: true,
            message: 'Database connection successful',
            timestamp: result.rows[0].now
        });
    } catch (error) {
        console.error('Database connection error:', error);
        res.status(500).json({
            success: false,
            message: 'Database connection failed',
            error: error.message
        });
    }
});

// Health check endpoint
app.get('/api/health', (req, res) => {
    res.json({ status: 'ok', message: 'Server is running' });
});

// Import routes
const productRoutes = require('./routes/productRoutes');
const userRoutes = require('./routes/userRoutes');
const orderRoutes = require('./routes/orderRoutes');
const addressRoutes = require('./routes/addressRoutes');
const reviewRoutes = require('./routes/reviewRoutes');

// Use routes
app.use('/api/products', productRoutes);
app.use('/api/users', userRoutes);
app.use('/api/orders', orderRoutes);
app.use('/api/addresses', addressRoutes);
app.use('/api/reviews', reviewRoutes);

// 404 handler for API routes only
app.use((req, res, next) => {
    if (req.path.startsWith('/api/')) {
        notFound(req, res);
    } else {
        next();
    }
});

// Error handling middleware
app.use(errorHandler);

// Start server
app.listen(PORT, '0.0.0.0', () => {
    const localIp = SERVER_IP;

    console.log('═══════════════════════════════════════════════════════');
    console.log('🚀 AlBaqer Gemstone Backend Server');
    console.log('═══════════════════════════════════════════════════════');
    console.log(`✅ Server running on port ${PORT}`);
    console.log(`📊 Environment: ${process.env.NODE_ENV || 'development'}`);
    console.log('');
    console.log('📱 Access URLs:');
    console.log(`   Local:            http://localhost:${PORT}/api`);
    console.log(`   Network:          http://${localIp}:${PORT}/api`);
    console.log(`   Android Emulator: http://10.0.2.2:${PORT}/api`);
    console.log('');
    console.log('⚙️  Update Flutter app config:');
    console.log(`   lib/config/api_config.dart → _baseIp = '${localIp}'`);
    console.log('═══════════════════════════════════════════════════════');
});

// Graceful shutdown
process.on('SIGTERM', () => {
    console.log('SIGTERM signal received: closing HTTP server');
    pool.end(() => {
        console.log('Database pool closed');
    });
});

module.exports = app;
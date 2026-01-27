const express = require('express');
const cors = require('cors');
const dotenv = require('dotenv');
const os = require('os');
const pool = require('./db/connection');
const { errorHandler, notFound } = require('./middleware/errorHandler');

// Load environment variables
dotenv.config();

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

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

// Use routes
app.use('/api/products', productRoutes);
app.use('/api/users', userRoutes);
app.use('/api/orders', orderRoutes);

// Error handling middleware
app.use(notFound);
app.use(errorHandler);

// Helper function to get local IP address
function getLocalIpAddress() {
    const interfaces = os.networkInterfaces();
    for (const name of Object.keys(interfaces)) {
        for (const iface of interfaces[name]) {
            // Skip internal and non-IPv4 addresses
            if (iface.family === 'IPv4' && !iface.internal) {
                return iface.address;
            }
        }
    }
    return 'localhost';
}

// Start server
app.listen(PORT, '0.0.0.0', () => {
    const localIp = getLocalIpAddress();

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
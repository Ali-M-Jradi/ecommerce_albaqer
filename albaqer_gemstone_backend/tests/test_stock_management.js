/**
 * Test Script: Stock Management & Inventory Control
 * 
 * Purpose: Test stock validation, decrement, and restoration
 * 
 * Tests:
 * 1. Stock validation before order creation
 * 2. Stock reduction when order is created
 * 3. Stock restoration when order is cancelled
 * 4. Stock restoration when order is deleted
 * 5. Low stock alerts
 * 6. Out of stock prevention
 */

const axios = require('axios');

const BASE_URL = 'http://localhost:3000/api';
let authToken = '';
let testProductId = null;
let testOrderId = null;

// Test configuration
const TEST_USER = {
    email: 'admin@test.com',
    password: 'admin123'
};

/**
 * Authenticate and get token
 */
async function authenticate() {
    try {
        console.log('\n🔐 Authenticating...');
        const response = await axios.post(`${BASE_URL}/users/login`, TEST_USER);
        authToken = response.data.token;
        console.log('✅ Authentication successful');
        return true;
    } catch (error) {
        console.error('❌ Authentication failed:', error.response?.data || error.message);
        return false;
    }
}

/**
 * Get a product with sufficient stock for testing
 */
async function getTestProduct() {
    try {
        console.log('\n🔍 Finding product with stock for testing...');
        const response = await axios.get(`${BASE_URL}/products`);

        // Find product with stock > 0
        const product = response.data.data.find(p => p.quantity_in_stock && p.quantity_in_stock > 2);

        if (!product) {
            console.error('❌ No products with sufficient stock found');
            return null;
        }

        testProductId = product.id;
        console.log(`✅ Found test product: "${product.name}" (ID: ${product.id}, Stock: ${product.quantity_in_stock})`);
        return product;
    } catch (error) {
        console.error('❌ Failed to get test product:', error.response?.data || error.message);
        return null;
    }
}

/**
 * Get current stock of a product
 */
async function getProductStock(productId) {
    try {
        const response = await axios.get(`${BASE_URL}/products/${productId}`);
        return response.data.data.quantity_in_stock;
    } catch (error) {
        console.error(`❌ Failed to get stock for product #${productId}:`, error.message);
        return null;
    }
}

/**
 * Test 1: Create order with valid stock
 */
async function testCreateOrderWithValidStock(product) {
    console.log('\n' + '='.repeat(60));
    console.log('TEST 1: Create Order with Valid Stock');
    console.log('='.repeat(60));

    try {
        const initialStock = await getProductStock(product.id);
        console.log(`📊 Initial stock: ${initialStock}`);

        const orderQuantity = 1;
        const orderData = {
            order_number: `TEST-STOCK-${Date.now()}`,
            total_amount: product.price * orderQuantity,
            tax_amount: product.price * orderQuantity * 0.1,
            shipping_cost: 5.00,
            discount_amount: 0,
            notes: 'Test order for stock management',
            order_items: [
                {
                    product_id: product.id,
                    quantity: orderQuantity,
                    price_at_purchase: product.price
                }
            ]
        };

        const response = await axios.post(`${BASE_URL}/orders`, orderData, {
            headers: { 'Authorization': `Bearer ${authToken}` }
        });

        testOrderId = response.data.data.id;
        console.log(`✅ Order created successfully (ID: ${testOrderId})`);

        // Verify stock was reduced
        const newStock = await getProductStock(product.id);
        const expectedStock = initialStock - orderQuantity;

        if (newStock === expectedStock) {
            console.log(`✅ Stock correctly reduced: ${initialStock} → ${newStock}`);
            return true;
        } else {
            console.error(`❌ Stock mismatch: Expected ${expectedStock}, got ${newStock}`);
            return false;
        }
    } catch (error) {
        console.error('❌ Test failed:', error.response?.data || error.message);
        return false;
    }
}

/**
 * Test 2: Try to create order with insufficient stock
 */
async function testCreateOrderWithInsufficientStock(product) {
    console.log('\n' + '='.repeat(60));
    console.log('TEST 2: Create Order with Insufficient Stock (Should Fail)');
    console.log('='.repeat(60));

    try {
        const currentStock = await getProductStock(product.id);
        const impossibleQuantity = currentStock + 100;

        console.log(`📊 Current stock: ${currentStock}`);
        console.log(`❌ Attempting to order: ${impossibleQuantity} (should fail)`);

        const orderData = {
            order_number: `TEST-OVERSTOCK-${Date.now()}`,
            total_amount: product.price * impossibleQuantity,
            order_items: [
                {
                    product_id: product.id,
                    quantity: impossibleQuantity,
                    price_at_purchase: product.price
                }
            ]
        };

        try {
            await axios.post(`${BASE_URL}/orders`, orderData, {
                headers: { 'Authorization': `Bearer ${authToken}` }
            });

            console.error('❌ FAILED: Order should have been rejected but was accepted');
            return false;
        } catch (error) {
            if (error.response?.status === 400 && error.response?.data?.stock_issues) {
                console.log('✅ PASSED: Order correctly rejected for insufficient stock');
                console.log('📄 Stock issues:', error.response.data.stock_issues);
                return true;
            } else {
                console.error('❌ Unexpected error:', error.response?.data || error.message);
                return false;
            }
        }
    } catch (error) {
        console.error('❌ Test failed:', error.message);
        return false;
    }
}

/**
 * Test 3: Cancel order and verify stock restoration
 */
async function testCancelOrderRestoresStock(productId, orderId) {
    console.log('\n' + '='.repeat(60));
    console.log('TEST 3: Cancel Order and Verify Stock Restoration');
    console.log('='.repeat(60));

    try {
        const stockBeforeCancel = await getProductStock(productId);
        console.log(`📊 Stock before cancel: ${stockBeforeCancel}`);

        // Cancel the order
        const response = await axios.put(
            `${BASE_URL}/orders/${orderId}/status`,
            { status: 'cancelled', tracking_number: null },
            { headers: { 'Authorization': `Bearer ${authToken}` } }
        );

        if (response.data.stock_restored) {
            console.log('✅ Stock restoration flag confirmed');
        }

        // Verify stock was restored
        const stockAfterCancel = await getProductStock(productId);
        console.log(`📊 Stock after cancel: ${stockAfterCancel}`);

        if (stockAfterCancel > stockBeforeCancel) {
            console.log(`✅ PASSED: Stock correctly restored (+${stockAfterCancel - stockBeforeCancel} units)`);
            return true;
        } else {
            console.error(`❌ FAILED: Stock not restored`);
            return false;
        }
    } catch (error) {
        console.error('❌ Test failed:', error.response?.data || error.message);
        return false;
    }
}

/**
 * Test 4: Get low stock products
 */
async function testGetLowStockProducts() {
    console.log('\n' + '='.repeat(60));
    console.log('TEST 4: Get Low Stock Products');
    console.log('='.repeat(60));

    try {
        const response = await axios.get(`${BASE_URL}/orders/inventory/low-stock?threshold=50`, {
            headers: { 'Authorization': `Bearer ${authToken}` }
        });

        console.log('✅ Low stock report retrieved');
        console.log('📊 Summary:', response.data.summary);

        if (response.data.summary.out_of_stock_count > 0) {
            console.warn(`⚠️  ${response.data.summary.out_of_stock_count} products are out of stock!`);
        }

        if (response.data.summary.critical_count > 0) {
            console.warn(`⚠️  ${response.data.summary.critical_count} products have critical stock levels!`);
        }

        return true;
    } catch (error) {
        console.error('❌ Test failed:', error.response?.data || error.message);
        return false;
    }
}

/**
 * Test 5: Delete order and verify stock restoration
 */
async function testDeleteOrderRestoresStock(product) {
    console.log('\n' + '='.repeat(60));
    console.log('TEST 5: Delete Order and Verify Stock Restoration');
    console.log('='.repeat(60));

    try {
        // Create a new order first
        const initialStock = await getProductStock(product.id);

        const orderData = {
            order_number: `TEST-DELETE-${Date.now()}`,
            total_amount: product.price,
            order_items: [
                {
                    product_id: product.id,
                    quantity: 1,
                    price_at_purchase: product.price
                }
            ]
        };

        const createResponse = await axios.post(`${BASE_URL}/orders`, orderData, {
            headers: { 'Authorization': `Bearer ${authToken}` }
        });

        const orderId = createResponse.data.data.id;
        console.log(`📦 Created order #${orderId} for deletion test`);

        const stockAfterCreate = await getProductStock(product.id);
        console.log(`📊 Stock after order creation: ${stockAfterCreate}`);

        // Delete the order
        const deleteResponse = await axios.delete(`${BASE_URL}/orders/${orderId}`, {
            headers: { 'Authorization': `Bearer ${authToken}` }
        });

        console.log('🗑️  Order deleted');

        // Verify stock was restored
        const finalStock = await getProductStock(product.id);
        console.log(`📊 Stock after deletion: ${finalStock}`);

        if (finalStock === initialStock) {
            console.log(`✅ PASSED: Stock correctly restored to initial level`);
            return true;
        } else {
            console.error(`❌ FAILED: Stock not restored correctly`);
            return false;
        }
    } catch (error) {
        console.error('❌ Test failed:', error.response?.data || error.message);
        return false;
    }
}

/**
 * Run all tests
 */
async function runTests() {
    console.log('🧪 Starting Stock Management Tests\n');
    console.log('='.repeat(60));

    let passedTests = 0;
    let failedTests = 0;

    // Authenticate
    if (!await authenticate()) {
        console.error('\n❌ Cannot proceed without authentication');
        return;
    }

    // Get test product
    const product = await getTestProduct();
    if (!product) {
        console.error('\n❌ Cannot proceed without test product');
        return;
    }

    // Run tests
    const tests = [
        { name: 'Create Order with Valid Stock', fn: () => testCreateOrderWithValidStock(product) },
        { name: 'Reject Order with Insufficient Stock', fn: () => testCreateOrderWithInsufficientStock(product) },
        { name: 'Cancel Order Restores Stock', fn: () => testCancelOrderRestoresStock(product.id, testOrderId) },
        { name: 'Get Low Stock Products', fn: () => testGetLowStockProducts() },
        { name: 'Delete Order Restores Stock', fn: () => testDeleteOrderRestoresStock(product) }
    ];

    for (const test of tests) {
        const result = await test.fn();
        if (result) {
            passedTests++;
        } else {
            failedTests++;
        }

        // Delay between tests
        await new Promise(resolve => setTimeout(resolve, 1000));
    }

    // Summary
    console.log('\n' + '='.repeat(60));
    console.log('📊 TEST SUMMARY');
    console.log('='.repeat(60));
    console.log(`✅ Passed: ${passedTests}`);
    console.log(`❌ Failed: ${failedTests}`);
    console.log(`📈 Total: ${passedTests + failedTests}`);

    if (failedTests === 0) {
        console.log('\n🎉 All stock management tests passed!');
    } else {
        console.log('\n⚠️  Some tests failed. Please review the errors above.');
    }
}

// Run the tests
runTests().catch(error => {
    console.error('💥 Test execution error:', error);
});

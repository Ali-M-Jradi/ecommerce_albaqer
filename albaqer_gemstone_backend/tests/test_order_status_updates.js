/**
 * Test Script: Order Status Update Validation
 * 
 * Purpose: Test all order status transitions and error handling
 * 
 * Tests:
 * 1. Valid status transitions
 * 2. Invalid status values
 * 3. Status constraint validation
 * 4. Error logging and messages
 */

const axios = require('axios');

const BASE_URL = 'http://localhost:3000/api';
let authToken = '';
let testOrderId = null;

// Test configuration
const TEST_USER = {
    email: 'admin@test.com',
    password: 'admin123'
};

// Valid status values
const VALID_STATUSES = [
    'pending',
    'confirmed',
    'assigned',
    'in_transit',
    'delivered',
    'cancelled'
];

// Invalid status values to test error handling
const INVALID_STATUSES = [
    'processing',  // Old status that should now fail
    'shipped',     // Old status that should now fail
    'refunded',    // Old status that should now fail
    'invalid',     // Completely invalid
    ''            // Empty string
];

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
 * Create a test order
 */
async function createTestOrder() {
    try {
        console.log('\n📦 Creating test order...');

        const orderData = {
            order_number: `TEST-ORDER-${Date.now()}`,
            total_amount: 100.00,
            tax_amount: 10.00,
            shipping_cost: 5.00,
            discount_amount: 0,
            shipping_address_id: 1, // Assumes address ID 1 exists
            notes: 'Test order for status updates',
            order_items: [
                {
                    product_id: 1, // Assumes product ID 1 exists
                    quantity: 1,
                    price_at_purchase: 100.00
                }
            ]
        };

        const response = await axios.post(`${BASE_URL}/orders`, orderData, {
            headers: { 'Authorization': `Bearer ${authToken}` }
        });

        testOrderId = response.data.data.id;
        console.log(`✅ Test order created with ID: ${testOrderId}`);
        return testOrderId;
    } catch (error) {
        console.error('❌ Failed to create test order:', error.response?.data || error.message);
        return null;
    }
}

/**
 * Test updating order status
 */
async function testStatusUpdate(orderId, status, shouldSucceed = true) {
    try {
        const response = await axios.put(
            `${BASE_URL}/orders/${orderId}/status`,
            { status, tracking_number: null },
            { headers: { 'Authorization': `Bearer ${authToken}` } }
        );

        if (shouldSucceed) {
            console.log(`✅ SUCCESS: Updated order to "${status}"`);
            return true;
        } else {
            console.error(`❌ FAILED: Status "${status}" should have been rejected but was accepted`);
            return false;
        }
    } catch (error) {
        if (!shouldSucceed) {
            console.log(`✅ EXPECTED: Status "${status}" was rejected`);
            if (error.response?.data?.message) {
                console.log(`   Message: ${error.response.data.message}`);
            }
            if (error.response?.data?.validStatuses) {
                console.log(`   Valid statuses: ${error.response.data.validStatuses.join(', ')}`);
            }
            return true;
        } else {
            console.error(`❌ FAILED: Status "${status}" should succeed but failed`);
            console.error(`   Error: ${error.response?.data?.message || error.message}`);
            return false;
        }
    }
}

/**
 * Run all tests
 */
async function runTests() {
    console.log('🧪 Starting Order Status Update Tests\n');
    console.log('='.repeat(60));

    let passedTests = 0;
    let failedTests = 0;

    // Step 1: Authenticate
    if (!await authenticate()) {
        console.error('\n❌ Cannot proceed without authentication');
        return;
    }

    // Step 2: Create test order
    const orderId = await createTestOrder();
    if (!orderId) {
        console.error('\n❌ Cannot proceed without test order');
        return;
    }

    console.log('\n' + '='.repeat(60));
    console.log('📋 Testing VALID Status Transitions');
    console.log('='.repeat(60));

    // Test 3: Test valid status transitions
    for (const status of VALID_STATUSES) {
        console.log(`\nTest: Update to "${status}"`);
        const result = await testStatusUpdate(orderId, status, true);
        if (result) passedTests++;
        else failedTests++;

        // Small delay between tests
        await new Promise(resolve => setTimeout(resolve, 500));
    }

    console.log('\n' + '='.repeat(60));
    console.log('🚫 Testing INVALID Status Values (Should Fail)');
    console.log('='.repeat(60));

    // Test 4: Test invalid status values
    for (const status of INVALID_STATUSES) {
        console.log(`\nTest: Update to "${status}" (should be rejected)`);
        const result = await testStatusUpdate(orderId, status, false);
        if (result) passedTests++;
        else failedTests++;

        await new Promise(resolve => setTimeout(resolve, 500));
    }

    // Summary
    console.log('\n' + '='.repeat(60));
    console.log('📊 TEST SUMMARY');
    console.log('='.repeat(60));
    console.log(`✅ Passed: ${passedTests}`);
    console.log(`❌ Failed: ${failedTests}`);
    console.log(`📈 Total: ${passedTests + failedTests}`);

    if (failedTests === 0) {
        console.log('\n🎉 All tests passed!');
    } else {
        console.log('\n⚠️  Some tests failed. Please review the errors above.');
    }
}

// Run the tests
runTests().catch(error => {
    console.error('💥 Test execution error:', error);
});

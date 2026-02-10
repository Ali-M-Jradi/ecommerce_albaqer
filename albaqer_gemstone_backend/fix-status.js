const pool = require('./db/connection');

async function fixStatusConstraint() {
    try {
        console.log('🔧 Fixing order status check constraint...');

        // Drop old constraint if exists
        await pool.query(`
            ALTER TABLE orders 
            DROP CONSTRAINT IF EXISTS orders_status_check
        `);

        console.log('✅ Old constraint removed');

        // Add new constraint with all allowed statuses
        await pool.query(`
            ALTER TABLE orders 
            ADD CONSTRAINT orders_status_check 
            CHECK (status IN ('pending', 'confirmed', 'assigned', 'in_transit', 'delivered', 'cancelled'))
        `);

        console.log('✅ New constraint added with all status values:');
        console.log('   - pending');
        console.log('   - confirmed');
        console.log('   - assigned');
        console.log('   - in_transit');
        console.log('   - delivered');
        console.log('   - cancelled');
        console.log('✅ Database constraint fixed! Status updates should now work.');
        process.exit(0);
    } catch (error) {
        console.error('❌ Error:', error.message);
        process.exit(1);
    }
}

fixStatusConstraint();

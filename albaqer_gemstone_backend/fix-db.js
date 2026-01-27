const pool = require('./db/connection');

async function fixDatabase() {
    try {
        console.log('🔧 Fixing database schema...');

        await pool.query(`
            ALTER TABLE orders 
            ALTER COLUMN shipping_address_id DROP NOT NULL,
            ALTER COLUMN billing_address_id DROP NOT NULL
        `);

        console.log('✅ Database fixed! Address fields are now optional.');
        process.exit(0);
    } catch (error) {
        console.error('❌ Error:', error.message);
        process.exit(1);
    }
}

fixDatabase();

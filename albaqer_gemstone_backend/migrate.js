// Migration runner script
// Usage: node migrate.js migrations/create_reviews_table.sql

const fs = require('fs');
const path = require('path');
require('dotenv').config();
const pool = require('./db/connection');

async function runMigration(migrationFile) {
    try {
        // Read the SQL file
        const sqlPath = path.join(__dirname, migrationFile);
        console.log(`📂 Reading migration file: ${sqlPath}`);

        if (!fs.existsSync(sqlPath)) {
            throw new Error(`Migration file not found: ${sqlPath}`);
        }

        const sql = fs.readFileSync(sqlPath, 'utf8');

        // Connect to database
        console.log('🔗 Connecting to database...');
        const client = await pool.connect();

        try {
            // Run the migration
            console.log('⚙️  Running migration...');
            await client.query(sql);
            console.log('✅ Migration completed successfully!');
        } finally {
            client.release();
        }

        // Close the pool
        await pool.end();
        console.log('🏁 Done!');

    } catch (error) {
        console.error('❌ Migration failed:', error.message);
        console.error(error);
        process.exit(1);
    }
}

// Get migration file from command line argument
const migrationFile = process.argv[2];

if (!migrationFile) {
    console.error('❌ Please provide a migration file path');
    console.error('Usage: node migrate.js migrations/your_migration.sql');
    process.exit(1);
}

// Run the migration
runMigration(migrationFile);

// Script to create test users with different roles
// Usage: node create_test_user.js <role> <email> <fullname> <password>
// Example: node create_test_user.js manager manager@test.com "Test Manager" password123

const bcrypt = require('bcryptjs');
const pool = require('./db/connection');

async function createUser(role, email, fullName, password) {
    try {
        console.log('🔐 Creating user...');
        console.log(`   Role: ${role}`);
        console.log(`   Email: ${email}`);
        console.log(`   Name: ${fullName}`);

        // Hash password
        const hashedPassword = await bcrypt.hash(password, 10);

        // Insert user
        const result = await pool.query(
            `INSERT INTO users (full_name, email, password, role, created_at, updated_at)
             VALUES ($1, $2, $3, $4, NOW(), NOW())
             RETURNING id, full_name, email, role`,
            [fullName, email, hashedPassword, role]
        );

        console.log('✅ User created successfully!');
        console.log(result.rows[0]);

    } catch (error) {
        if (error.code === '23505') {
            // Unique violation - email already exists
            console.error('❌ Email already exists. Use update_user_role.js instead.');
        } else {
            console.error('❌ Error creating user:', error.message);
        }
    } finally {
        await pool.end();
    }
}

// Parse command line arguments
const args = process.argv.slice(2);

if (args.length < 4) {
    console.log('Usage: node create_test_user.js <role> <email> <fullname> <password>');
    console.log('');
    console.log('Roles: user, admin, manager, delivery_man');
    console.log('');
    console.log('Examples:');
    console.log('  node create_test_user.js manager manager@test.com "Test Manager" password123');
    console.log('  node create_test_user.js delivery_man delivery@test.com "Test Delivery" password123');
    process.exit(1);
}

const [role, email, fullName, password] = args;

// Validate role
const validRoles = ['user', 'admin', 'manager', 'delivery_man'];
if (!validRoles.includes(role)) {
    console.error(`❌ Invalid role: ${role}`);
    console.error(`   Valid roles: ${validRoles.join(', ')}`);
    process.exit(1);
}

// Create user
createUser(role, email, fullName, password);

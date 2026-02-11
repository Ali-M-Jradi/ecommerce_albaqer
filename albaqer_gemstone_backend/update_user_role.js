// Script to update existing user's role
// Usage: node update_user_role.js <email> <new_role>
// Example: node update_user_role.js john@example.com manager

const pool = require('./db/connection');

async function updateUserRole(email, newRole) {
    try {
        console.log('🔄 Updating user role...');
        console.log(`   Email: ${email}`);
        console.log(`   New Role: ${newRole}`);

        // Update user role
        const result = await pool.query(
            `UPDATE users 
             SET role = $1, updated_at = NOW()
             WHERE email = $2
             RETURNING id, full_name, email, role`,
            [newRole, email]
        );

        if (result.rows.length === 0) {
            console.error('❌ User not found with email:', email);
            console.log('💡 Tip: Register the user first, then update their role');
        } else {
            console.log('✅ User role updated successfully!');
            console.log(result.rows[0]);
        }

    } catch (error) {
        console.error('❌ Error updating user role:', error.message);
    } finally {
        await pool.end();
    }
}

// Parse command line arguments
const args = process.argv.slice(2);

if (args.length < 2) {
    console.log('Usage: node update_user_role.js <email> <new_role>');
    console.log('');
    console.log('Roles: customer, admin, manager, delivery_man');
    console.log('');
    console.log('Examples:');
    console.log('  node update_user_role.js john@example.com manager');
    console.log('  node update_user_role.js jane@example.com delivery_man');
    console.log('');
    console.log('Workflow:');
    console.log('  1. User registers normally through app (becomes customer)');
    console.log('  2. Run this script to promote them to manager/delivery_man');
    process.exit(1);
}

const [email, newRole] = args;

// Validate role
const validRoles = ['customer', 'admin', 'manager', 'delivery_man'];
if (!validRoles.includes(newRole)) {
    console.error(`❌ Invalid role: ${newRole}`);
    console.error(`   Valid roles: ${validRoles.join(', ')}`);
    process.exit(1);
}

// Update user role
updateUserRole(email, newRole);

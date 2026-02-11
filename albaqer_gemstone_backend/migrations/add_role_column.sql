-- Migration to add role column and migrate from is_admin to role-based system
-- Run this migration if your users table still uses is_admin BOOLEAN

-- Step 1: Add role column if it doesn't exist
ALTER TABLE users 
ADD COLUMN IF NOT EXISTS role VARCHAR(20) DEFAULT 'customer';

-- Step 2: Migrate existing is_admin values to role
-- If is_admin is TRUE, set role to 'admin', otherwise set to 'customer'
UPDATE users 
SET role = CASE 
    WHEN is_admin = TRUE THEN 'admin'
    ELSE 'customer'
END
WHERE role = 'customer'; -- Only update records that haven't been manually set

-- Step 3: Add NOT NULL constraint after data migration
ALTER TABLE users 
ALTER COLUMN role SET NOT NULL;

-- Step 4: (Optional) Drop is_admin column if no longer needed
-- Uncomment the line below if you want to remove the old is_admin column
-- ALTER TABLE users DROP COLUMN IF EXISTS is_admin;

-- Step 5: Add check constraint for valid roles
ALTER TABLE users 
ADD CONSTRAINT IF NOT EXISTS check_user_role 
CHECK (role IN ('customer', 'admin', 'manager', 'delivery_man'));

-- Step 6: Create index on role column for faster queries
CREATE INDEX IF NOT EXISTS idx_users_role ON users(role);

-- Verify the migration
SELECT 
    'Migration completed. User role distribution:' AS message;
    
SELECT 
    role, 
    COUNT(*) as count
FROM users 
GROUP BY role
ORDER BY role;

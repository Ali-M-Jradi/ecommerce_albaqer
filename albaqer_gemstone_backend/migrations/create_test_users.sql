-- ============================================================================
-- CREATE TEST USERS FOR DIFFERENT ROLES
-- ============================================================================
-- Use this script to create test users for manager and delivery man roles
-- Password for all test users: "password123" (hashed with bcrypt)

-- NOTE: Run this AFTER users have registered normally, OR insert new users here

-- ============================================================================
-- OPTION 1: Update existing users to different roles
-- ============================================================================

-- Change existing user to MANAGER role
-- Replace 'manager@test.com' with actual email
UPDATE users 
SET role = 'manager' 
WHERE email = 'manager@test.com';

-- Change existing user to DELIVERY_MAN role  
-- Replace 'delivery@test.com' with actual email
UPDATE users 
SET role = 'delivery_man' 
WHERE email = 'delivery@test.com';

-- Verify the changes
SELECT id, full_name, email, role 
FROM users 
WHERE role IN ('manager', 'delivery_man');

-- ============================================================================
-- OPTION 2: Insert new users directly with specific roles
-- ============================================================================

-- Insert MANAGER user
-- Password: "password123" (bcrypt hash shown below)
INSERT INTO users (full_name, email, password, role, created_at, updated_at)
VALUES (
    'Test Manager',
    'manager@test.com',
    '$2a$10$rT8vqVqK8K5pJ5X8Y5p5eOqJ5p5eOqJ5p5eOqJ5p5eOqJ5p5eOqJ5',  -- password123
    'manager',
    NOW(),
    NOW()
) ON CONFLICT (email) DO NOTHING;

-- Insert DELIVERY MAN user
INSERT INTO users (full_name, email, password, role, created_at, updated_at)
VALUES (
    'Test Delivery Person',
    'delivery@test.com',
    '$2a$10$rT8vqVqK8K5pJ5X8Y5p5eOqJ5p5eOqJ5p5eOqJ5p5eOqJ5p5eOqJ5',  -- password123
    'delivery_man',
    NOW(),
    NOW()
) ON CONFLICT (email) DO NOTHING;

-- Insert ADMIN user (if not exists)
INSERT INTO users (full_name, email, password, role, created_at, updated_at)
VALUES (
    'Test Admin',
    'admin@test.com',
    '$2a$10$rT8vqVqK8K5pJ5X8Y5p5eOqJ5p5eOqJ5p5eOqJ5p5eOqJ5p5eOqJ5',  -- password123
    'admin',
    NOW(),
    NOW()
) ON CONFLICT (email) DO NOTHING;

-- ============================================================================
-- VERIFY ALL USERS BY ROLE
-- ============================================================================

SELECT 
    id,
    full_name,
    email,
    role,
    created_at
FROM users
ORDER BY role, created_at DESC;

-- ============================================================================
-- USEFUL QUERIES
-- ============================================================================

-- Count users by role
SELECT role, COUNT(*) as count
FROM users
GROUP BY role;

-- List all delivery people
SELECT id, full_name, email
FROM users
WHERE role = 'delivery_man';

-- List all managers
SELECT id, full_name, email
FROM users
WHERE role = 'manager';

-- ============================================================================
-- NOTES FOR REAL PASSWORD HASHING
-- ============================================================================
-- The password hash above is a PLACEHOLDER and won't work!
-- 
-- To create REAL test users with proper password hashing:
-- 1. Register users normally through the app UI
-- 2. Then update their roles using OPTION 1 above
-- 
-- OR use Node.js bcrypt to generate proper hashes:
-- const bcrypt = require('bcryptjs');
-- const hash = await bcrypt.hash('password123', 10);
-- console.log(hash);

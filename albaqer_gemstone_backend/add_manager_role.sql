-- Migration: Add manager role support
-- This migration adds the ability for managers to assign orders to delivery personnel

-- Add delivery_man_id column to orders table if it doesn't exist
ALTER TABLE orders 
ADD COLUMN IF NOT EXISTS delivery_man_id INTEGER REFERENCES users(id) ON DELETE SET NULL;

-- Add assignment_date column to track when order was assigned to delivery_man
ALTER TABLE orders 
ADD COLUMN IF NOT EXISTS assigned_at TIMESTAMP;

-- Create index for faster queries on delivery_man_id
CREATE INDEX IF NOT EXISTS idx_orders_delivery_man_id ON orders(delivery_man_id);

-- Update existing role constraints if needed (users can now be: customer, admin, manager, delivery_man)
-- This is handled at the application level, but you can add a CHECK constraint if needed:
-- ALTER TABLE users ADD CONSTRAINT check_role CHECK (role IN ('customer', 'admin', 'manager', 'delivery_man'));

-- Grant manager role to specific users (run manually as needed):
-- UPDATE users SET role = 'manager' WHERE email = 'manager@example.com';

-- Grant delivery_man role to specific users (run manually as needed):
-- UPDATE users SET role = 'delivery_man' WHERE email = 'deliveryman@example.com';

COMMIT;

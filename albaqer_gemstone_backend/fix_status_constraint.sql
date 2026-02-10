-- Migration: Fix order status check constraint
-- This removes the old CHECK constraint and adds a new one that allows all status values

-- Remove the old CHECK constraint
ALTER TABLE orders 
DROP CONSTRAINT IF EXISTS orders_status_check;

-- Add new CHECK constraint with all allowed statuses
ALTER TABLE orders 
ADD CONSTRAINT orders_status_check 
CHECK (status IN ('pending', 'confirmed', 'assigned', 'in_transit', 'delivered', 'cancelled'));

COMMIT;

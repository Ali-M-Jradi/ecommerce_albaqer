-- Migration to add manager role support
-- Adds delivery assignment tracking to orders table

-- Add delivery_man_id and assigned_at columns to orders table
ALTER TABLE orders 
ADD COLUMN IF NOT EXISTS delivery_man_id INTEGER REFERENCES users(id) ON DELETE SET NULL,
ADD COLUMN IF NOT EXISTS assigned_at TIMESTAMP;

-- Create index for faster queries on delivery_man_id
CREATE INDEX IF NOT EXISTS idx_orders_delivery_man_id ON orders(delivery_man_id);

-- Create index for faster queries on assigned_at
CREATE INDEX IF NOT EXISTS idx_orders_assigned_at ON orders(assigned_at);

-- Update comment
COMMENT ON COLUMN orders.delivery_man_id IS 'ID of the delivery person assigned to this order';
COMMENT ON COLUMN orders.assigned_at IS 'Timestamp when order was assigned to delivery person';

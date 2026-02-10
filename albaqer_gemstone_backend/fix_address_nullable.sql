-- Migration: Fix shipping_address_id NOT NULL constraint
-- This migration makes shipping_address_id and billing_address_id nullable
-- since orders can be created before addresses are assigned

ALTER TABLE orders ALTER COLUMN shipping_address_id DROP NOT NULL;
ALTER TABLE orders ALTER COLUMN billing_address_id DROP NOT NULL;

-- Verify the changes
-- \d orders

COMMIT;

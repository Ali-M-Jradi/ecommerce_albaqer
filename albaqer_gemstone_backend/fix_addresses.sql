-- Make address fields optional in orders table
ALTER TABLE orders 
ALTER COLUMN shipping_address_id DROP NOT NULL,
ALTER COLUMN billing_address_id DROP NOT NULL;

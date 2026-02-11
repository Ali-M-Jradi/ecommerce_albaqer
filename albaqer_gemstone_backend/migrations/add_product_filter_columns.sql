-- Migration: Add Product Filter Columns
-- Date: 2026-02-11
-- Purpose: Add columns needed for advanced product filtering (P2-1)

-- Add category column (Ring, Necklace, Bracelet, Earrings, Prayer Beads)
ALTER TABLE products 
ADD COLUMN IF NOT EXISTS category VARCHAR(50);

-- Add gender column (men, women, unisex)
ALTER TABLE products 
ADD COLUMN IF NOT EXISTS gender VARCHAR(20) DEFAULT 'unisex';

-- Add Islamic significance tags (sunnah, protection, healing, success, etc.)
ALTER TABLE products 
ADD COLUMN IF NOT EXISTS islamic_tags TEXT;

-- Add available sizes (for rings, necklaces, bracelets)
ALTER TABLE products 
ADD COLUMN IF NOT EXISTS available_sizes TEXT;

-- Create indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_products_category ON products(category);
CREATE INDEX IF NOT EXISTS idx_products_gender ON products(gender);
CREATE INDEX IF NOT EXISTS idx_products_metal_type ON products(metal_type);
CREATE INDEX IF NOT EXISTS idx_products_stone_type ON products(stone_type);
CREATE INDEX IF NOT EXISTS idx_products_stone_color ON products(stone_color);
CREATE INDEX IF NOT EXISTS idx_products_is_available ON products(is_available);
CREATE INDEX IF NOT EXISTS idx_products_average_rating ON products(average_rating);
CREATE INDEX IF NOT EXISTS idx_products_base_price ON products(base_price);

-- Add comments for documentation
COMMENT ON COLUMN products.category IS 'Product category: ring, necklace, bracelet, earrings, prayer_beads';
COMMENT ON COLUMN products.gender IS 'Target gender: men, women, unisex';
COMMENT ON COLUMN products.islamic_tags IS 'Comma-separated tags: sunnah, protection, healing, success, prosperity, imam_ali, etc.';
COMMENT ON COLUMN products.available_sizes IS 'Comma-separated sizes: 6,7,8,9 for rings, 14,18,24 for necklaces';

-- Example: Update existing products with sample data
-- (You can customize this based on your actual products)

-- Set categories based on product type
UPDATE products SET category = 'ring' WHERE type ILIKE '%ring%' AND category IS NULL;
UPDATE products SET category = 'necklace' WHERE (type ILIKE '%necklace%' OR type ILIKE '%pendant%') AND category IS NULL;
UPDATE products SET category = 'bracelet' WHERE type ILIKE '%bracelet%' AND category IS NULL;
UPDATE products SET category = 'earrings' WHERE type ILIKE '%earring%' AND category IS NULL;
UPDATE products SET category = 'prayer_beads' WHERE (type ILIKE '%prayer%' OR type ILIKE '%tasbih%' OR type ILIKE '%misbaha%') AND category IS NULL;

-- Set default gender based on product characteristics
-- (You'll need to manually update specific products for accuracy)
UPDATE products SET gender = 'unisex' WHERE gender IS NULL;

-- Add sample Islamic tags to products
-- (Customize based on your product knowledge)
UPDATE products SET islamic_tags = 'sunnah,protection' 
WHERE stone_type ILIKE '%agate%' AND islamic_tags IS NULL;

UPDATE products SET islamic_tags = 'sunnah,healing,success' 
WHERE stone_type ILIKE '%ruby%' AND islamic_tags IS NULL;

UPDATE products SET islamic_tags = 'sunnah,prosperity' 
WHERE stone_type ILIKE '%emerald%' AND islamic_tags IS NULL;

-- Add default available sizes for rings
UPDATE products SET available_sizes = '6,7,8,9,10,11,12' 
WHERE category = 'ring' AND available_sizes IS NULL;

-- Add default available sizes for necklaces
UPDATE products SET available_sizes = '14,16,18,20,24,30' 
WHERE category = 'necklace' AND available_sizes IS NULL;

-- Add default available sizes for bracelets
UPDATE products SET available_sizes = 'small,medium,large,xlarge' 
WHERE category = 'bracelet' AND available_sizes IS NULL;

COMMENT ON TABLE products IS 'Products table with advanced filtering support';

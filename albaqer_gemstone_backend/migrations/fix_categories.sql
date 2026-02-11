-- Fix category column mapping from type column
-- The original migration had a bug with earring vs earrings

-- Update all categories based on product type
UPDATE products SET category = 'earrings' WHERE type ILIKE '%earring%';
UPDATE products SET category = 'bracelet' WHERE type ILIKE '%bracelet%' OR type ILIKE '%bangle%';
UPDATE products SET category = 'necklace' WHERE type ILIKE '%necklace%' OR type ILIKE '%pendant%';
UPDATE products SET category = 'ring' WHERE type ILIKE '%ring%';
UPDATE products SET category = 'prayer_beads' WHERE type ILIKE '%prayer%' OR type ILIKE '%tasbih%' OR type ILIKE '%misbaha%';

-- Verify results
SELECT COUNT(*) as count, category 
FROM products 
GROUP BY category 
ORDER BY category;

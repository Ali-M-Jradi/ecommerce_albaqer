-- Update product image URLs
UPDATE products SET image_url = '/images/products/ruby-gold-ring.jpg' WHERE name LIKE '%Ruby%';
UPDATE products SET image_url = '/images/products/emerald-silver-ring.jpg' WHERE name LIKE '%Emerald%';
UPDATE products SET image_url = '/images/products/sapphire-platinum-ring.jpg' WHERE name LIKE '%Sapphire%';
UPDATE products SET image_url = '/images/products/diamond-pearl-necklace.jpg' WHERE name LIKE '%Diamond%';
UPDATE products SET image_url = '/images/products/amethyst-gold-necklace.jpg' WHERE name LIKE '%Amethyst%';
UPDATE products SET image_url = '/images/products/topaz-silver-necklace.jpg' WHERE name LIKE '%Topaz%';
UPDATE products SET image_url = '/images/products/opal-gold-earrings.jpg' WHERE name LIKE '%Opal%';
UPDATE products SET image_url = '/images/products/garnet-silver-earrings.jpg' WHERE name LIKE '%Garnet%';
UPDATE products SET image_url = '/images/products/aquamarine-platinum-earrings.jpg' WHERE name LIKE '%Aquamarine%';
UPDATE products SET image_url = '/images/products/tourmaline-gold-bracelet.jpg' WHERE name LIKE '%Tourmaline%';

-- Verify updates
SELECT id, name, image_url FROM products ORDER BY id;

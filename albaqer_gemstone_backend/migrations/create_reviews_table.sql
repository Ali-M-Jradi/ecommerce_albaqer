-- Migration: Create reviews table and update products table for ratings
-- Run this script to set up the reviews system

-- Create reviews table
CREATE TABLE IF NOT EXISTS reviews (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    product_id INTEGER NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    order_id INTEGER REFERENCES orders(id) ON DELETE SET NULL,
    rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
    title VARCHAR(255) NOT NULL,
    comment TEXT,
    is_verified_purchase BOOLEAN DEFAULT FALSE,
    helpful_count INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Ensure one review per user per product
    UNIQUE(user_id, product_id)
);

-- Add indexes for common queries
CREATE INDEX IF NOT EXISTS idx_reviews_product_id ON reviews(product_id);
CREATE INDEX IF NOT EXISTS idx_reviews_user_id ON reviews(user_id);
CREATE INDEX IF NOT EXISTS idx_reviews_rating ON reviews(rating);
CREATE INDEX IF NOT EXISTS idx_reviews_created_at ON reviews(created_at DESC);

-- Update products table to add rating fields if they don't exist
DO $$ 
BEGIN
    -- Add average_rating column
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'products' AND column_name = 'average_rating'
    ) THEN
        ALTER TABLE products ADD COLUMN average_rating DECIMAL(3,2) DEFAULT 0;
    END IF;
    
    -- Add review_count column
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'products' AND column_name = 'review_count'
    ) THEN
        ALTER TABLE products ADD COLUMN review_count INTEGER DEFAULT 0;
    END IF;
END $$;

-- Create function to update review timestamp
CREATE OR REPLACE FUNCTION update_review_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger to auto-update updated_at
DROP TRIGGER IF EXISTS trigger_update_review_timestamp ON reviews;
CREATE TRIGGER trigger_update_review_timestamp
    BEFORE UPDATE ON reviews
    FOR EACH ROW
    EXECUTE FUNCTION update_review_updated_at();

-- Optional: Populate initial ratings from existing reviews (if any)
-- This is safe to run even if reviews table is empty
UPDATE products p
SET 
    average_rating = COALESCE(
        (SELECT AVG(rating) FROM reviews WHERE product_id = p.id), 
        0
    ),
    review_count = COALESCE(
        (SELECT COUNT(*) FROM reviews WHERE product_id = p.id), 
        0
    );

-- Verify setup
SELECT 'Reviews table created successfully!' as status;
SELECT 'Columns in reviews table:' as info;
SELECT column_name, data_type, column_default 
FROM information_schema.columns 
WHERE table_name = 'reviews' 
ORDER BY ordinal_position;

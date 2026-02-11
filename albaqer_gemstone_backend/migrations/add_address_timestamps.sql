-- Add missing timestamp columns to addresses table if they don't exist
-- Run this migration if you get errors about created_at or updated_at columns

-- Check if columns exist and add them if needed
DO $$ 
BEGIN
    -- Add created_at column if it doesn't exist
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'addresses' AND column_name = 'created_at'
    ) THEN
        ALTER TABLE addresses ADD COLUMN created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP;
        RAISE NOTICE 'Added created_at column to addresses table';
    END IF;

    -- Add updated_at column if it doesn't exist
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'addresses' AND column_name = 'updated_at'
    ) THEN
        ALTER TABLE addresses ADD COLUMN updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP;
        RAISE NOTICE 'Added updated_at column to addresses table';
    END IF;
END $$;

-- Create index for faster user queries
CREATE INDEX IF NOT EXISTS idx_addresses_user_id ON addresses(user_id);

-- Display current addresses table structure
SELECT 
    column_name, 
    data_type, 
    is_nullable, 
    column_default
FROM 
    information_schema.columns
WHERE 
    table_name = 'addresses'
ORDER BY 
    ordinal_position;

-- Add 'fit' column to tshirts table if it doesn't exist
ALTER TABLE public.tshirts ADD COLUMN IF NOT EXISTS fit text;

-- Notify PostgREST to reload the schema cache
NOTIFY pgrst, 'reload config';

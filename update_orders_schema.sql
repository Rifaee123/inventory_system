-- Update Orders Table Schema for Order Management Module
-- Adds customer information, delivery charges, and enhanced status tracking

-- Add customer information fields
ALTER TABLE public.orders 
ADD COLUMN IF NOT EXISTS customer_name TEXT DEFAULT 'Guest',
ADD COLUMN IF NOT EXISTS customer_email TEXT,
ADD COLUMN IF NOT EXISTS customer_phone TEXT,
ADD COLUMN IF NOT EXISTS delivery_address TEXT,
ADD COLUMN IF NOT EXISTS delivery_charges NUMERIC DEFAULT 0;

-- Update status column default to 'pending'
ALTER TABLE public.orders 
ALTER COLUMN status SET DEFAULT 'pending';

-- Add comment to explain status values
COMMENT ON COLUMN public.orders.status IS 'Order status: pending, accepted, dispatched, shipped, out_for_delivery, delivered, cancelled';

-- Update RLS policies if needed
ALTER TABLE public.orders ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Public read orders" ON public.orders;
DROP POLICY IF EXISTS "Public insert orders" ON public.orders;
DROP POLICY IF EXISTS "Public update orders" ON public.orders;
DROP POLICY IF EXISTS "Public delete orders" ON public.orders;

-- Create new policies for public access (update later with proper auth)
CREATE POLICY "Public read orders" ON public.orders FOR SELECT USING (true);
CREATE POLICY "Public insert orders" ON public.orders FOR INSERT WITH CHECK (true);
CREATE POLICY "Public update orders" ON public.orders FOR UPDATE USING (true);
CREATE POLICY "Public delete orders" ON public.orders FOR DELETE USING (true);

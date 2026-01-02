-- Enable RLS (Should be already enabled, but good to ensure)
ALTER TABLE public.categories ENABLE ROW LEVEL SECURITY;

-- Drop existing policies to avoid conflicts
DROP POLICY IF EXISTS "Public read categories" ON public.categories;
DROP POLICY IF EXISTS "Public insert categories" ON public.categories;
DROP POLICY IF EXISTS "Authenticated insert categories" ON public.categories;
DROP POLICY IF EXISTS "Enable read access for all users" ON public.categories;
DROP POLICY IF EXISTS "Enable insert for all users" ON public.categories;
DROP POLICY IF EXISTS "Enable all access for all users" ON public.categories;

-- Create comprehensive policies
-- 1. Allow everyone to READ categories
CREATE POLICY "Enable read access for all users"
ON public.categories FOR SELECT
USING (true);

-- 2. Allow everyone to INSERT categories
CREATE POLICY "Enable insert for all users"
ON public.categories FOR INSERT
WITH CHECK (true);

-- 3. Allow everyone to UPDATE categories (Just in case)
CREATE POLICY "Enable update for all users"
ON public.categories FOR UPDATE
USING (true);

-- 4. Allow everyone to DELETE categories
CREATE POLICY "Enable delete for all users"
ON public.categories FOR DELETE
USING (true);

-- Enable RLS (Should be already enabled)
ALTER TABLE public.tshirts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.variants ENABLE ROW LEVEL SECURITY;

-- 1. TSHIRTS POLICIES
-- Drop existing policies to avoid conflicts
DROP POLICY IF EXISTS "Public read tshirts" ON public.tshirts;
DROP POLICY IF EXISTS "Public insert tshirts" ON public.tshirts;
DROP POLICY IF EXISTS "Public update tshirts" ON public.tshirts;
DROP POLICY IF EXISTS "Public delete tshirts" ON public.tshirts;
DROP POLICY IF EXISTS "Enable read access for all users" ON public.tshirts;
DROP POLICY IF EXISTS "Enable insert for all users" ON public.tshirts;
DROP POLICY IF EXISTS "Enable update for all users" ON public.tshirts;
DROP POLICY IF EXISTS "Enable delete for all users" ON public.tshirts;

-- Create comprehensive policies for tshirts
CREATE POLICY "Enable read access for all users" ON public.tshirts FOR SELECT USING (true);
CREATE POLICY "Enable insert for all users" ON public.tshirts FOR INSERT WITH CHECK (true);
CREATE POLICY "Enable update for all users" ON public.tshirts FOR UPDATE USING (true);
CREATE POLICY "Enable delete for all users" ON public.tshirts FOR DELETE USING (true);

-- 2. VARIANTS POLICIES
-- Drop existing policies
DROP POLICY IF EXISTS "Public read variants" ON public.variants;
DROP POLICY IF EXISTS "Public all variants" ON public.variants;
DROP POLICY IF EXISTS "Enable read access for all users" ON public.variants;
DROP POLICY IF EXISTS "Enable all access for all users" ON public.variants;

-- Create comprehensive policies for variants
CREATE POLICY "Enable read access for all users" ON public.variants FOR SELECT USING (true);
CREATE POLICY "Enable insert for all users" ON public.variants FOR INSERT WITH CHECK (true);
CREATE POLICY "Enable update for all users" ON public.variants FOR UPDATE USING (true);
CREATE POLICY "Enable delete for all users" ON public.variants FOR DELETE USING (true);

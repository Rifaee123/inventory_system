-- FIX DB SETUP
-- Run this script to finish your setup. It handles permissions and data safely.

-- PART 1: FIX PERMISSIONS (Make it public for development)
-- We drop existing policies first to avoid "policy already exists" errors.

-- Categories
DROP POLICY IF EXISTS "Public read categories" ON public.categories;
DROP POLICY IF EXISTS "Authenticated insert categories" ON public.categories;
DROP POLICY IF EXISTS "Public insert categories" ON public.categories;
CREATE POLICY "Public read categories" ON public.categories FOR SELECT USING (true);
CREATE POLICY "Public insert categories" ON public.categories FOR INSERT WITH CHECK (true);

-- T-Shirts
DROP POLICY IF EXISTS "Public read tshirts" ON public.tshirts;
DROP POLICY IF EXISTS "Authenticated insert tshirts" ON public.tshirts;
DROP POLICY IF EXISTS "Authenticated update tshirts" ON public.tshirts;
DROP POLICY IF EXISTS "Authenticated delete tshirts" ON public.tshirts;
DROP POLICY IF EXISTS "Public insert tshirts" ON public.tshirts;
DROP POLICY IF EXISTS "Public update tshirts" ON public.tshirts;
DROP POLICY IF EXISTS "Public delete tshirts" ON public.tshirts;

CREATE POLICY "Public read tshirts" ON public.tshirts FOR SELECT USING (true);
CREATE POLICY "Public insert tshirts" ON public.tshirts FOR INSERT WITH CHECK (true);
CREATE POLICY "Public update tshirts" ON public.tshirts FOR UPDATE USING (true);
CREATE POLICY "Public delete tshirts" ON public.tshirts FOR DELETE USING (true);

-- Variants
DROP POLICY IF EXISTS "Public read variants" ON public.variants;
DROP POLICY IF EXISTS "Authenticated all variants" ON public.variants;
DROP POLICY IF EXISTS "Public all variants" ON public.variants;
CREATE POLICY "Public read variants" ON public.variants FOR SELECT USING (true);
CREATE POLICY "Public all variants" ON public.variants FOR ALL USING (true);

-- PART 2: SEED DATA (Only adds if missing)
INSERT INTO public.categories (name, tax_percentage)
SELECT 'Graphic Tees', 5.0
WHERE NOT EXISTS (SELECT 1 FROM public.categories WHERE name = 'Graphic Tees');

INSERT INTO public.categories (name, tax_percentage)
SELECT 'Basic Essentials', 0.0
WHERE NOT EXISTS (SELECT 1 FROM public.categories WHERE name = 'Basic Essentials');

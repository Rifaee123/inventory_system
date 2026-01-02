-- BYPASS AUTHENTICATION FOR DEVELOPMENT
-- Run this script to allow data insertion (Add Product) without logging in.

-- 1. Categories
DROP POLICY IF EXISTS "Authenticated insert categories" ON public.categories;
CREATE POLICY "Public insert categories" ON public.categories FOR INSERT WITH CHECK (true);

-- 2. T-Shirts (Products)
DROP POLICY IF EXISTS "Authenticated insert tshirts" ON public.tshirts;
DROP POLICY IF EXISTS "Authenticated update tshirts" ON public.tshirts;
DROP POLICY IF EXISTS "Authenticated delete tshirts" ON public.tshirts;

CREATE POLICY "Public insert tshirts" ON public.tshirts FOR INSERT WITH CHECK (true);
CREATE POLICY "Public update tshirts" ON public.tshirts FOR UPDATE USING (true);
CREATE POLICY "Public delete tshirts" ON public.tshirts FOR DELETE USING (true);

-- 3. Variants
DROP POLICY IF EXISTS "Authenticated all variants" ON public.variants;
CREATE POLICY "Public all variants" ON public.variants FOR ALL USING (true);

-- 4. Storage (Images)
DROP POLICY IF EXISTS "Auth Upload" ON storage.objects;
CREATE POLICY "Public Upload" ON storage.objects FOR INSERT WITH CHECK (bucket_id = 'products');

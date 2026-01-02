-- Seed required categories for the dropdown
INSERT INTO public.categories (name, tax_percentage)
VALUES 
  ('Oversized', 5.0),
  ('Old Money Outfit', 12.0)
ON CONFLICT DO NOTHING;
-- Note: 'name' usually isn't a unique constraint unless defined, assuming strict equality check or just hoping for no dupes if ID is auto-gen. 
-- Since ID is uuid default gen, we might duplicate if we run multiple times without constraint.
-- Ideally we check existence first.

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM public.categories WHERE name = 'Oversized') THEN
        INSERT INTO public.categories (name, tax_percentage) VALUES ('Oversized', 5.0);
    END IF;

    IF NOT EXISTS (SELECT 1 FROM public.categories WHERE name = 'Old Money Outfit') THEN
        INSERT INTO public.categories (name, tax_percentage) VALUES ('Old Money Outfit', 12.0);
    END IF;
END $$;

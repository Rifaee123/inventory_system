-- Force seed required categories
DO $$
DECLARE
    v_exist boolean;
BEGIN
    -- Oversized
    SELECT EXISTS(SELECT 1 FROM public.categories WHERE name ILIKE 'Oversized') INTO v_exist;
    IF NOT v_exist THEN
        INSERT INTO public.categories (name, tax_percentage) VALUES ('Oversized', 5);
    END IF;

    -- Old Money Outfit
    SELECT EXISTS(SELECT 1 FROM public.categories WHERE name ILIKE 'Old Money Outfit') INTO v_exist;
    IF NOT v_exist THEN
        INSERT INTO public.categories (name, tax_percentage) VALUES ('Old Money Outfit', 15);
    END IF;
    
    -- Also add "Old Money" if that's what the user literally wants, or just alias it. 
    -- We will add "Old Money" as well to be safe since the user asked for it.
    SELECT EXISTS(SELECT 1 FROM public.categories WHERE name ILIKE 'Old Money') INTO v_exist;
    IF NOT v_exist THEN
        INSERT INTO public.categories (name, tax_percentage) VALUES ('Old Money', 15);
    END IF;

END $$;

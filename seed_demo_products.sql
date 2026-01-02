DO $$
DECLARE
    -- Category IDs
    v_cat_basics_id uuid;
    v_cat_vintage_id uuid;
    v_cat_street_id uuid;
    v_cat_summer_id uuid;
    v_cat_active_id uuid;
    
    -- Product IDs
    v_prod1_id uuid;
    v_prod2_id uuid;
    v_prod3_id uuid;
    v_prod4_id uuid;
    v_prod5_id uuid;
BEGIN
    -- 1. GET OR CREATE CATEGORIES
    
    -- Basics
    SELECT id INTO v_cat_basics_id FROM public.categories WHERE name = 'Basics' LIMIT 1;
    IF v_cat_basics_id IS NULL THEN
        INSERT INTO public.categories (name, tax_percentage) VALUES ('Basics', 5) RETURNING id INTO v_cat_basics_id;
    END IF;

    -- Vintage
    SELECT id INTO v_cat_vintage_id FROM public.categories WHERE name = 'Vintage' LIMIT 1;
    IF v_cat_vintage_id IS NULL THEN
        INSERT INTO public.categories (name, tax_percentage) VALUES ('Vintage', 12) RETURNING id INTO v_cat_vintage_id;
    END IF;
    
    -- Streetwear
    SELECT id INTO v_cat_street_id FROM public.categories WHERE name = 'Streetwear' LIMIT 1;
    IF v_cat_street_id IS NULL THEN
        INSERT INTO public.categories (name, tax_percentage) VALUES ('Streetwear', 18) RETURNING id INTO v_cat_street_id;
    END IF;

    -- Summer Collection
    SELECT id INTO v_cat_summer_id FROM public.categories WHERE name = 'Summer Collection' LIMIT 1;
    IF v_cat_summer_id IS NULL THEN
        INSERT INTO public.categories (name, tax_percentage) VALUES ('Summer Collection', 8) RETURNING id INTO v_cat_summer_id;
    END IF;

    -- Activewear
    SELECT id INTO v_cat_active_id FROM public.categories WHERE name = 'Activewear' LIMIT 1;
    IF v_cat_active_id IS NULL THEN
        INSERT INTO public.categories (name, tax_percentage) VALUES ('Activewear', 5) RETURNING id INTO v_cat_active_id;
    END IF;

    -- 2. INSERT PRODUCTS AND VARIANTS

    -- Product 1: Classic White Tee
    INSERT INTO public.tshirts (name, description, category_id, base_price, offer_price, return_policy_days, priority_weight, is_active)
    VALUES ('Classic White Tee', 'Essential premium cotton white t-shirt.', v_cat_basics_id, 25.00, null, 30, 10, true)
    RETURNING id INTO v_prod1_id;

    INSERT INTO public.variants (tshirt_id, size, color, stock_quantity) VALUES
    (v_prod1_id, 'S', 'White', 50),
    (v_prod1_id, 'M', 'White', 100),
    (v_prod1_id, 'L', 'White', 75),
    (v_prod1_id, 'XL', 'White', 25);

    -- Product 2: Rolling Stones Vintage Wash
    INSERT INTO public.tshirts (name, description, category_id, base_price, offer_price, return_policy_days, priority_weight, is_active)
    VALUES ('Rolling Stones Vintage Wash', 'Acid wash graphic tee with vintage vibes.', v_cat_vintage_id, 45.00, 39.99, 14, 20, true)
    RETURNING id INTO v_prod2_id;

    INSERT INTO public.variants (tshirt_id, size, color, stock_quantity) VALUES
    (v_prod2_id, 'M', 'Charcoal', 30),
    (v_prod2_id, 'L', 'Charcoal', 20);

    -- Product 3: Urban Oversized Hoodie
    INSERT INTO public.tshirts (name, description, category_id, base_price, offer_price, return_policy_days, priority_weight, is_active)
    VALUES ('Urban Oversized Hoodie', 'Heavyweight french terry oversized hoodie.', v_cat_street_id, 85.00, null, 30, 50, true)
    RETURNING id INTO v_prod3_id;

    INSERT INTO public.variants (tshirt_id, size, color, stock_quantity) VALUES
    (v_prod3_id, 'M', 'Black', 40),
    (v_prod3_id, 'L', 'Black', 40),
    (v_prod3_id, 'M', 'Beige', 25);

    -- Product 4: Linen Resort Shirt
    INSERT INTO public.tshirts (name, description, category_id, base_price, offer_price, return_policy_days, priority_weight, is_active)
    VALUES ('Linen Resort Shirt', 'Breathable linen shirt perfect for summer.', v_cat_summer_id, 55.00, 45.00, 15, 5, true)
    RETURNING id INTO v_prod4_id;

    INSERT INTO public.variants (tshirt_id, size, color, stock_quantity) VALUES
    (v_prod4_id, 'S', 'Light Blue', 15),
    (v_prod4_id, 'M', 'Light Blue', 30),
    (v_prod4_id, 'L', 'White', 20);

    -- Product 5: Performance Gym Tee
    INSERT INTO public.tshirts (name, description, category_id, base_price, offer_price, return_policy_days, priority_weight, is_active)
    VALUES ('Performance Gym Tee', 'Moisture-wicking athletic fit tee.', v_cat_active_id, 30.00, null, 30, 15, true)
    RETURNING id INTO v_prod5_id;

    INSERT INTO public.variants (tshirt_id, size, color, stock_quantity) VALUES
    (v_prod5_id, 'M', 'Navy', 60),
    (v_prod5_id, 'L', 'Navy', 55),
    (v_prod5_id, 'XL', 'Grey', 40);

END $$;

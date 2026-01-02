-- PROMOTION SCRIPT: Run this AFTER you have successfully signed up as 'admin@stitch.com' in the app.

UPDATE public.profiles
SET role = 'admin'
WHERE id IN (
    SELECT id FROM auth.users WHERE email = 'admin@stitch.com'
);

-- Verify the update
SELECT * FROM public.profiles WHERE role = 'admin';

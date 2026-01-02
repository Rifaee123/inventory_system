-- ENABLE ADMIN SCRIPT: Run this to validte the email and promote the user to admin.

-- 1. Manually confirm the email (bypasses the need to click the email link)
UPDATE auth.users
SET email_confirmed_at = NOW()
WHERE email = 'admin@stitch.com';

-- 2. Promote to Admin role
UPDATE public.profiles
SET role = 'admin'
WHERE id IN (
    SELECT id FROM auth.users WHERE email = 'admin@stitch.com'
);

-- 3. Verify the result
SELECT email, email_confirmed_at FROM auth.users WHERE email = 'admin@stitch.com';
SELECT * FROM public.profiles WHERE role = 'admin';

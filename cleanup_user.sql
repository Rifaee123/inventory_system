-- CLEANUP SCRIPT: Run this to remove the corrupted admin user.

-- 1. Delete the user from auth.users (this will cascade delete the profile too)
DELETE FROM auth.users WHERE email = 'admin@stitch.com';

-- 2. Delete the user from public.profiles just in case (though cascade should handle it)
DELETE FROM public.profiles WHERE username = 'AdminUser';

-- 3. (Optional) Fix the trigger just in case it's still broken, using a simpler version without metadata reliance if that was the issue.
CREATE OR REPLACE FUNCTION public.handle_new_user() 
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, username, role)
  VALUES (
    new.id, 
    -- Fallback to distinct username if metadata is missing
    COALESCE(new.raw_user_meta_data->>'username', 'user_' || substr(new.id::text, 1, 8)),
    'user'
  )
  ON CONFLICT (id) DO NOTHING;
  RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

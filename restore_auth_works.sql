-- RESTORE SCRIPT: Run this to re-enable the automatic profile creation trigger properly.
-- This uses the "SAFE" version of the trigger that prevents the 500 errors.

-- 1. Clean up old artifacts just in case
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
DROP FUNCTION IF EXISTS public.handle_new_user();

-- 2. Create the SAFE Function
-- Uses security definer to bypass RLS during insertion
-- Uses COALESCE to handle missing metadata
-- Uses ON CONFLICT to prevent crashes if profile exists
CREATE OR REPLACE FUNCTION public.handle_new_user() 
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, username, role)
  VALUES (
    new.id, 
    COALESCE(new.raw_user_meta_data->>'username', 'User'),
    'user'
  )
  ON CONFLICT (id) DO NOTHING;
  
  RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

-- 3. Create the Trigger
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();

-- 4. Verify RLS Policies are present
DO $$ 
BEGIN
    -- Ensure policies exist (re-applying them is harmless and safe)
    DROP POLICY IF EXISTS "Public profiles viewable" ON public.profiles;
    CREATE POLICY "Public profiles viewable" ON public.profiles FOR SELECT USING (true);

    DROP POLICY IF EXISTS "Users can insert own profile" ON public.profiles;
    CREATE POLICY "Users can insert own profile" ON public.profiles FOR INSERT WITH CHECK (auth.uid() = id);

    DROP POLICY IF EXISTS "Users can update own profile" ON public.profiles;
    CREATE POLICY "Users can update own profile" ON public.profiles FOR UPDATE USING (auth.uid() = id);
END $$;

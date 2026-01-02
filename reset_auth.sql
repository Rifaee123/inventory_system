-- RESET SCRIPT: Run this to completely clear all users and triggers.
-- This is necessary because the previous "seed" data seems to have corrupted the auth state.

-- 1. Drop the trigger causing potential issues
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
DROP FUNCTION IF EXISTS public.handle_new_user();

-- 2. Delete ALL users (This will cascade delete profiles)
DELETE FROM auth.users;

-- 3. Re-create the structure cleanly (but NO TRIGGER yet, to verify basic auth works)
-- We will add the trigger back ONLY after verifying simple signup works.

-- Ensure profiles table exists
CREATE TABLE IF NOT EXISTS public.profiles (
  id UUID REFERENCES auth.users ON DELETE CASCADE PRIMARY KEY,
  username TEXT,
  role public.user_role DEFAULT 'user' NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- Simple policies (No auth.uid checks during insert to avoid recursion risk for now)
DO $$ 
BEGIN
    DROP POLICY IF EXISTS "Public profiles viewable" ON public.profiles;
    CREATE POLICY "Public profiles viewable" ON public.profiles FOR SELECT USING (true);

    DROP POLICY IF EXISTS "Users can insert own profile" ON public.profiles;
    CREATE POLICY "Users can insert own profile" ON public.profiles FOR INSERT WITH CHECK (auth.uid() = id);

    DROP POLICY IF EXISTS "Users can update own profile" ON public.profiles;
    CREATE POLICY "Users can update own profile" ON public.profiles FOR UPDATE USING (auth.uid() = id);
END $$;

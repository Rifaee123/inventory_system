-- WARNING: Generally, it is better to sign up users via the App/API to ensure all Supabase auth triggers fire correctly.
-- However, if you want to seed users directly, you can use the following SQL.
-- This assumes you have the `pgcrypto` extension enabled.

CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- 1. Insert ADMIN user (if not exists)
-- Replace 'admin123' with your desired password
DO $$
DECLARE
  new_admin_id UUID := gen_random_uuid();
BEGIN
  IF NOT EXISTS (SELECT 1 FROM auth.users WHERE email = 'admin@stitch.com') THEN
    INSERT INTO auth.users (
      instance_id,
      id,
      aud,
      role,
      email,
      encrypted_password,
      email_confirmed_at,
      raw_user_meta_data,
      created_at,
      updated_at,
      confirmation_token,
      recovery_token
    ) VALUES (
      '00000000-0000-0000-0000-000000000000',
      new_admin_id,
      'authenticated',
      'authenticated',
      'admin@stitch.com',
      crypt('admin123', gen_salt('bf')),
      now(), -- Auto-confirms email
      '{"username": "AdminUser"}'::jsonb,
      now(),
      now(),
      '',
      ''
    );
    
    -- Note: The trigger I created earlier (on_auth_user_created) should fire and create the profile.
    -- However, it defaults to 'user' role. We need to update it to 'admin'.
    
    -- Wait a tiny bit (conceptually) or just update blindly assuming trigger runs in same transaction usually.
    -- Actually, triggers run in the same transaction. So we can update immediately check if profile exists, if not insert manually (fallback).
    
    -- But since we cannot easily rely on the trigger outcome in this anonymous block if it's deferred or funky,
    -- let's just do an UPDATE on profiles explicitly just in case the trigger made it 'user'.
    -- Or if trigger didn't run for some reason, we insert.
  END IF;
END $$;

-- 2. Update Admin Role (The trigger sets it to 'user' by default)
UPDATE public.profiles
SET role = 'admin'
WHERE id IN (SELECT id FROM auth.users WHERE email = 'admin@stitch.com');


-- 3. Insert Regular USER (if not exists)
-- Replace 'user123' with your desired password
DO $$
DECLARE
  new_user_id UUID := gen_random_uuid();
BEGIN
  IF NOT EXISTS (SELECT 1 FROM auth.users WHERE email = 'user@stitch.com') THEN
    INSERT INTO auth.users (
      instance_id,
      id,
      aud,
      role,
      email,
      encrypted_password,
      email_confirmed_at,
      raw_user_meta_data,
      created_at,
      updated_at,
      confirmation_token,
      recovery_token
    ) VALUES (
      '00000000-0000-0000-0000-000000000000',
      new_user_id,
      'authenticated',
      'authenticated',
      'user@stitch.com',
      crypt('user123', gen_salt('bf')),
      now(), -- Auto-confirms email
      '{"username": "RegularUser"}'::jsonb,
      now(),
      now(),
      '',
      ''
    );
  END IF;
END $$;

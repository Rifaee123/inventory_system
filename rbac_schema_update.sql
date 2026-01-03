-- 1. Update Profiles Table
-- Ensure profiles table exists (it should via auth triggers, but let's be safe or just alter)
-- We assume public.profiles is linked to auth.users.
alter table public.profiles add column if not exists full_name text;
alter table public.profiles add column if not exists shipping_address text;
-- Role default is already likely handled, but we can set default if needed:
-- alter table public.profiles alter column role set default 'user';

-- 2. Update TShirts Table
-- is_active should already be there, but let's ensure it.
alter table public.tshirts add column if not exists is_active boolean default true;

-- 3. Update Orders Table
alter table public.orders add column if not exists user_id uuid references public.profiles(id);

-- 4. Enable RLS
alter table public.tshirts enable row level security;
alter table public.orders enable row level security;
alter table public.profiles enable row level security;

-- 5. Policies for TShirts
-- Drop existing loose policies if any
drop policy if exists "Public read tshirts" on public.tshirts;
drop policy if exists "Public insert tshirts" on public.tshirts;
drop policy if exists "Public update tshirts" on public.tshirts;
drop policy if exists "Public delete tshirts" on public.tshirts;

-- Create new policies
-- Everyone can view active tshirts (User Catalog)
create policy "Public view active tshirts" 
on public.tshirts for select 
using (true);

-- Admins have full access
create policy "Admins have full access to tshirts" 
on public.tshirts for all 
using ( (select role from public.profiles where id = auth.uid()) = 'admin' );

-- 6. Policies for Orders
-- Drop existing loose policies
drop policy if exists "Authenticated all orders" on public.orders;

-- Users can see their own orders
create policy "Users can view own orders" 
on public.orders for select 
using ( auth.uid() = user_id );

-- Users can insert their own orders
create policy "Users can insert own orders" 
on public.orders for insert 
with check ( auth.uid() = user_id );

-- Admins can view and update all orders
create policy "Admins can manage all orders" 
on public.orders for all 
using ( (select role from public.profiles where id = auth.uid()) = 'admin' );

-- 7. Policies for Profiles
drop policy if exists "Users can view own profile" on public.profiles;
drop policy if exists "Users can update own profile" on public.profiles;

create policy "Users can view own profile" 
on public.profiles for select 
using ( auth.uid() = id );

create policy "Users can update own profile" 
on public.profiles for update 
using ( auth.uid() = id );

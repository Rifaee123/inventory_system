-- Enable UUID extension
create extension if not exists "uuid-ossp";

-- CATEGORIES
create table public.categories (
  id uuid primary key default uuid_generate_v4(),
  name text not null,
  tax_percentage numeric default 0,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- TSHIRTS
create table public.tshirts (
  id uuid primary key default uuid_generate_v4(),
  name text not null,
  description text,
  category_id uuid references public.categories(id),
  image_url text,
  base_price numeric not null,
  offer_price numeric,
  return_policy_days integer default 7,
  priority_weight integer default 0,
  is_active boolean default true,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- VARIANTS (Size, Color, Stock)
create table public.variants (
  id uuid primary key default uuid_generate_v4(),
  tshirt_id uuid references public.tshirts(id) on delete cascade,
  size text not null, -- XS, S, M, L, XL, XXL
  color text not null, -- Hex code or name
  stock_quantity integer default 0,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- REVIEWS
create table public.reviews (
  id uuid primary key default uuid_generate_v4(),
  tshirt_id uuid references public.tshirts(id) on delete cascade,
  user_name text default 'Anonymous',
  rating integer check (rating >= 1 and rating <= 5),
  comment text,
  status text default 'pending', -- pending, published
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- ORDERS
create table public.orders (
  id uuid primary key default uuid_generate_v4(),
  total_amount numeric not null,
  tax_amount numeric default 0,
  shipping_cost numeric default 0,
  status text default 'completed',
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- ORDER ITEMS (For precise profit calculation)
create table public.order_items (
  id uuid primary key default uuid_generate_v4(),
  order_id uuid references public.orders(id) on delete cascade,
  variant_id uuid references public.variants(id),
  quantity integer not null,
  sale_price numeric not null, -- Price at moment of sale
  cost_price numeric not null, -- Cost at moment of sale (for profit calc)
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Storage bucket for product images
insert into storage.buckets (id, name, public) values ('products', 'products', true);

-- RLS Policies (Modified for Public Access / No Auth)
alter table public.categories enable row level security;
create policy "Public read categories" on public.categories for select using (true);
create policy "Public insert categories" on public.categories for insert with check (true);

alter table public.tshirts enable row level security;
create policy "Public read tshirts" on public.tshirts for select using (true);
create policy "Public insert tshirts" on public.tshirts for insert with check (true);
create policy "Public update tshirts" on public.tshirts for update using (true);
create policy "Public delete tshirts" on public.tshirts for delete using (true);

alter table public.variants enable row level security;
create policy "Public read variants" on public.variants for select using (true);
create policy "Public all variants" on public.variants for all using (true);

alter table public.reviews enable row level security;
create policy "Public read published reviews" on public.reviews for select using (status = 'published');
create policy "Public insert reviews" on public.reviews for insert with check (true);

alter table public.orders enable row level security;
create policy "Authenticated all orders" on public.orders for all using (true); -- Opened for demo

alter table public.order_items enable row level security;
create policy "Authenticated all order_items" on public.order_items for all using (true); -- Opened for demo

-- Storage policies
create policy "Public Access" on storage.objects for select using ( bucket_id = 'products' );
create policy "Public Upload" on storage.objects for insert with check ( bucket_id = 'products' );

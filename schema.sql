-- ============================================================
-- PARK Institutions — Seminar Hall Booking System
-- Supabase schema. Run this whole file once in:
-- Supabase Dashboard -> SQL Editor -> New query -> paste -> Run
-- ============================================================

-- 1. USERS (super_admin / hod / staff) --------------------------------
create table if not exists app_users (
  id uuid primary key default gen_random_uuid(),
  username text unique not null,
  password_hash text not null,   -- SHA-256 hex, generated in the browser
  name text not null,
  role text not null check (role in ('super_admin','hod','staff')),
  department text,               -- required for hod, optional for staff
  mobile text,
  is_active boolean default true,
  created_at timestamptz default now()
);

-- 2. HALLS --------------------------------------------------------------
create table if not exists halls (
  id serial primary key,
  name text not null,
  code text not null,
  capacity int not null,
  sort_order int default 0
);

insert into halls (name, code, capacity, sort_order) values
  ('Seminar Hall - 1 (TP)', 'SH1', 200, 1),
  ('Seminar Hall - 2 (TP)', 'SH2', 150, 2),
  ('Seminar Hall - 3 (TP)', 'SH3', 100, 3),
  ('New Seminar Hall (MB)', 'NSH', 80, 4),
  ('Auditorium', 'AUD', 800, 5)
on conflict do nothing;

-- 3. PERIODS (reference only, used by the UI) ---------------------------
create table if not exists periods (
  id int primary key,
  label text not null
);

insert into periods (id, label) values
  (1, '9:00 - 9:50 AM'),
  (2, '9:50 - 10:40 AM'),
  (3, '10:40 - 11:30 AM'),
  (4, '11:40 - 12:30 PM'),
  (5, '1:30 - 2:20 PM'),
  (6, '2:20 - 3:10 PM'),
  (7, '3:20 - 4:10 PM')
on conflict do nothing;

-- 4. BOOKINGS -------------------------------------------------------------
create table if not exists bookings (
  id uuid primary key default gen_random_uuid(),
  hall_id int references halls(id) not null,
  department text not null,          -- routes the request to that HoD
  function_name text not null,
  chief_guest text,
  booking_staff_mobile text not null,
  students_count int,
  staff_incharge_name text,
  staff_incharge_mobile text,
  student_incharge_name text,
  student_incharge_mobile text,
  food_arrangement text,
  snacks_arrangement text,
  notes text,
  status text not null default 'pending'
    check (status in ('pending','approved','rejected','altered','cancelled')),
  is_emergency boolean default false,
  hod_remarks text,
  hod_id uuid references app_users(id),
  approved_at timestamptz,
  created_by uuid references app_users(id) not null,
  created_by_name text not null,       -- denormalised for easy display/printing
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

-- 5. BOOKING SLOTS (one row per date + period, used for clash checks) -----
create table if not exists booking_slots (
  id uuid primary key default gen_random_uuid(),
  booking_id uuid references bookings(id) on delete cascade not null,
  hall_id int references halls(id) not null,
  booking_date date not null,
  period_id int references periods(id) not null
);

create index if not exists idx_slots_hall_date on booking_slots (hall_id, booking_date);
create index if not exists idx_bookings_department on bookings (department);
create index if not exists idx_bookings_status on bookings (status);

-- 6. SIGNOFFS — the 9 offices printed at the bottom of the approval sheet -
create table if not exists booking_signoffs (
  id uuid primary key default gen_random_uuid(),
  booking_id uuid references bookings(id) on delete cascade not null,
  office text not null,      -- e.g. 'Staff Incharge', 'HoD', 'Principal' ...
  sort_order int not null
);

-- helper to auto-create the 9 signoff rows whenever a booking is approved
create or replace function create_signoffs_on_approval()
returns trigger as $$
begin
  if new.status = 'approved' and old.status is distinct from 'approved' then
    insert into booking_signoffs (booking_id, office, sort_order) values
      (new.id, 'Staff Incharge', 1),
      (new.id, 'HoD', 2),
      (new.id, 'Principal', 3),
      (new.id, 'House Keeping', 4),
      (new.id, 'Electrical', 5),
      (new.id, 'AO', 6),
      (new.id, 'Director', 7),
      (new.id, 'PRO', 8),
      (new.id, 'System Manager', 9)
    on conflict do nothing;
  end if;
  return new;
end;
$$ language plpgsql;

drop trigger if exists trg_create_signoffs on bookings;
create trigger trg_create_signoffs
  after update on bookings
  for each row execute function create_signoffs_on_approval();

-- 7. ROW LEVEL SECURITY ----------------------------------------------------
-- NOTE: This app uses its own username/password login stored in app_users
-- (not Supabase Auth), so RLS cannot check "who" is calling — it can only
-- control WHAT is allowed. That is fine for a college-internal tool used
-- only from the pages you deploy, but keep your Supabase anon key as the
-- public key it is meant to be (never the service_role key) and don't
-- expose the SQL editor. If you later want per-role server-side security,
-- migrate logins to Supabase Auth + Edge Functions.

alter table app_users enable row level security;
alter table halls enable row level security;
alter table periods enable row level security;
alter table bookings enable row level security;
alter table booking_slots enable row level security;
alter table booking_signoffs enable row level security;

create policy "read halls" on halls for select using (true);
create policy "read periods" on periods for select using (true);

create policy "read users for login" on app_users for select using (true);
create policy "insert users" on app_users for insert with check (true);
create policy "update users" on app_users for update using (true);

create policy "read bookings" on bookings for select using (true);
create policy "insert bookings" on bookings for insert with check (true);
create policy "update bookings" on bookings for update using (true);

create policy "read slots" on booking_slots for select using (true);
create policy "insert slots" on booking_slots for insert with check (true);
create policy "delete slots" on booking_slots for delete using (true);

create policy "read signoffs" on booking_signoffs for select using (true);

-- 8. SEED SUPER ADMIN -------------------------------------------------------
-- username: superadmin
-- password: ParkAdmin#2026   (change this after first login — see README)
insert into app_users (username, password_hash, name, role)
values (
  'superadmin',
  '50e216c6fa821e25a40b794c49b5a9870a56cc270a41321843a3e38b6ff64ade',
  'Super Admin',
  'super_admin'
)
on conflict (username) do nothing;

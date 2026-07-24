-- ============================================================
-- Migration 3 — run this AFTER schema.sql and migration-2.sql
-- (Supabase Dashboard -> SQL Editor -> New query -> paste -> Run)
--
-- Adds:
--  - Hostellers / Day Scholars breakdown (validated to equal total)
--  - Simple Yes/No Food & Snacks flags (replacing the old per-item text)
--  - "Any other faculty required" field
--  - Special requirements / notes field
--  - Staff username stamped on each booking (for the print form's "Staff ID")
--  - Hall management: active / maintenance / disabled status, editable name & capacity
--  - Live sync: adds bookings/booking_halls/booking_slots to Supabase Realtime so
--    all three portals update instantly without needing a manual refresh
-- ============================================================

alter table bookings
  add column if not exists hostel_count int,
  add column if not exists dayscholar_count int,
  add column if not exists hostel_boys int,
  add column if not exists hostel_girls int,
  add column if not exists food_required boolean default false,
  add column if not exists snacks_required boolean default false,
  add column if not exists other_faculty_required boolean default false,
  add column if not exists other_faculty_details text,
  add column if not exists special_requirements text,
  add column if not exists created_by_username text;

alter table halls
  add column if not exists status text default 'active' check (status in ('active','maintenance','disabled'));

-- allow Super Admin to manage halls (add / edit / disable / delete)
drop policy if exists "update halls" on halls;
drop policy if exists "insert halls" on halls;
drop policy if exists "delete halls" on halls;
create policy "update halls" on halls for update using (true);
create policy "insert halls" on halls for insert with check (true);
create policy "delete halls" on halls for delete using (true);

-- Live sync across Staff / HoD / Super Admin portals
alter publication supabase_realtime add table bookings;
alter publication supabase_realtime add table booking_halls;
alter publication supabase_realtime add table booking_slots;

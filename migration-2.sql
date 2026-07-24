-- ============================================================
-- Migration 2 — run this AFTER your original schema.sql
-- (Supabase Dashboard -> SQL Editor -> New query -> paste -> Run)
-- Adds support for booking MULTIPLE halls in one request, each
-- with its own student count.
-- ============================================================

-- A booking can now cover more than one hall (e.g. an overflow
-- event held in 3 halls at once), so hall_id on bookings is no
-- longer required.
alter table bookings alter column hall_id drop not null;
alter table bookings alter column students_count drop not null;

-- One row per hall selected for a booking.
create table if not exists booking_halls (
  id uuid primary key default gen_random_uuid(),
  booking_id uuid references bookings(id) on delete cascade not null,
  hall_id int references halls(id) not null,
  students_count int not null
);

alter table booking_halls enable row level security;

create policy "read booking_halls" on booking_halls for select using (true);
create policy "insert booking_halls" on booking_halls for insert with check (true);
create policy "delete booking_halls" on booking_halls for delete using (true);

create index if not exists idx_booking_halls_booking on booking_halls (booking_id);

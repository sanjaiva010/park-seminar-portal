# PARK Institutions — Seminar Hall Booking System

A purple, minimal booking system with three logins:
- **Super Admin** — creates HoD and Staff logins, sees everything
- **HoD** — approves / rejects / alters bookings for their department
- **Staff** — books a hall, checks period-wise availability, tracks status

Built with plain HTML/CSS/JS + Supabase (matches your other projects), so it deploys to GitHub Pages for free.

---

## 1. Create the database (5 minutes)

1. Go to https://supabase.com → sign in → **New project**.
2. Give it any name (e.g. `park-seminar-booking`), set a database password (save it somewhere), pick a region close to you, click **Create new project**. Wait ~2 minutes for it to finish setting up.
3. In the left sidebar click **SQL Editor** → **New query**.
4. Open `schema.sql` from this folder, copy **all** of it, paste it into the SQL editor, click **Run**.
   - This creates all tables, the 5 halls, the 7 periods, and one Super Admin login.
5. Then open a **New query** again, paste in all of `migration-2.sql`, and click **Run**.
   - This adds support for booking more than one hall in a single request (each with its own student count).
5. In the left sidebar click **Project Settings → API**.
   - Copy the **Project URL**.
   - Copy the **anon / public** key (NOT the `service_role` key — never share that one).

## 2. Connect the website to your database

1. Open `js/supabase-config.js` in any text editor.
2. Replace:
   ```js
   const SUPABASE_URL = "https://YOUR-PROJECT-REF.supabase.co";
   const SUPABASE_ANON_KEY = "YOUR-ANON-PUBLIC-KEY";
   ```
   with the Project URL and anon key you copied in step 1.
3. Save the file.

## 3. Super Admin login

The database was seeded with one Super Admin account:

```
Username: superadmin
Password: ParkAdmin#2026
```

Open `index.html`, choose the **Super Admin** tab, and sign in with the above. **Change this password** as soon as you're in, by asking me to help you generate a new password hash and update it in Supabase (Table Editor → `app_users` → edit the `superadmin` row's `password_hash`) — or just tell me the new password you want and I'll give you the exact SQL to run.

From the Super Admin dashboard → **Manage Logins**, you can create as many HoD and Staff accounts as you need. Each one needs:
- Role (HoD or Staff)
- Name
- Department (for HoD, this is the department whose bookings they approve — it must match exactly what staff type into the "Department" field when booking, e.g. both use `CSE`)
- Mobile
- Username & password — share these directly with that person

## 4. Try it locally before deploying

You can't just double-click `index.html` because browsers block some features on `file://` pages. Easiest option:
- If you have **VS Code**, install the "Live Server" extension, right-click `index.html` → "Open with Live Server".
- Or run this in a terminal from inside the project folder: `python3 -m http.server 8000`, then open `http://localhost:8000` in your browser.

## 5. Deploy to GitHub Pages (same as your other projects)

1. Create a new GitHub repository (e.g. `park-seminar-hall-booking`).
2. Upload every file in this folder, keeping the `css/` and `js/` folders intact.
3. Go to the repo's **Settings → Pages**.
4. Under "Build and deployment", set **Source: Deploy from a branch**, branch: `main`, folder: `/ (root)`. Save.
5. Wait 1–2 minutes, then your site will be live at:
   `https://YOUR-GITHUB-USERNAME.github.io/park-seminar-hall-booking/`

Share that link with your HoDs and staff — they'll land on the login page and pick the right tab (Staff / HoD).

---

## How the workflow works

1. **Staff** logs in → fills the event form → picks **Single day** or **Multiple days**, and checks off which of the 7 periods they need per day. Already-booked periods for that hall/date show greyed out automatically.
2. The booking appears on the **HoD dashboard** for that exact department (matched by the "Department" text), status = *Pending*.
3. HoD can:
   - **Approve** — booking is confirmed, an approval sheet becomes available to print.
   - **Reject** — with a remark visible to the staff member.
   - **Alter & approve** — for emergency/short-notice cases: HoD can change the hall, date, or periods and approve it in one step (the system re-checks for clashes before saving).
4. Once approved, anyone with the link (Staff, HoD, or Super Admin) can open **Print approval sheet** — a clean A4 layout with the event details and 9 signature lines at the bottom: Staff Incharge, HoD, Principal, House Keeping, Electrical, AO, Director, PRO, System Manager.
5. **Super Admin** can see every booking across every department, and manage (enable/disable) all logins at any time.

## A note on security

Logins are checked against your own `app_users` table (not Supabase's built-in auth), which keeps things simple and matches how your other projects work — but it means the browser talks to Supabase using a public "anon" key, so please:
- Never share your `service_role` key with anyone or put it in these files.
- Treat this as an internal-network / trusted-users tool rather than a public internet app.
- If you later want bank-grade security (server-side password checks), tell me and I'll help you migrate logins to Supabase Auth + Edge Functions — happy to do that as a next step once the core system is working for you.

## Files in this folder

```
index.html          Login page (role tabs: Staff / HoD / Super Admin)
staff.html           Staff dashboard — new booking + booking history
hod.html             HoD dashboard — pending approvals, all requests, alter mode
super-admin.html     Super Admin dashboard — manage logins, all bookings, halls
print.html           A4 printable approval sheet
schema.sql            Run once in Supabase SQL Editor
css/style.css         Shared purple/minimal design system
js/supabase-config.js Your Supabase URL + anon key (fill this in)
js/auth.js             Shared login/session helper functions
```

Ping me once you've run the schema and filled in `supabase-config.js` — I can walk you through creating your first HoD and Staff login, or help troubleshoot anything that doesn't work first try.

// ============================================================
// Shared auth + small utility helpers
// ============================================================

async function sha256Hex(text) {
  const enc = new TextEncoder().encode(text);
  const buf = await crypto.subtle.digest("SHA-256", enc);
  return Array.from(new Uint8Array(buf)).map(b => b.toString(16).padStart(2, "0")).join("");
}

function saveSession(user) {
  sessionStorage.setItem("psb_user", JSON.stringify(user));
}
function getSession() {
  const raw = sessionStorage.getItem("psb_user");
  return raw ? JSON.parse(raw) : null;
}
function clearSession() {
  sessionStorage.removeItem("psb_user");
}
// Redirects to index.html if not logged in / wrong role. Call at top of each dashboard page.
function requireRole(role) {
  const u = getSession();
  if (!u || u.role !== role) {
    window.location.href = "index.html";
    return null;
  }
  return u;
}
function logout() {
  clearSession();
  window.location.href = "index.html";
}

async function login(username, password, expectedRole) {
  const password_hash = await sha256Hex(password);
  const { data, error } = await supabaseClient
    .from("app_users")
    .select("*")
    .eq("username", username.trim())
    .eq("is_active", true)
    .maybeSingle();

  if (error) throw error;
  if (!data) return { ok: false, message: "No account found with that username." };
  if (data.password_hash !== password_hash) return { ok: false, message: "Incorrect password." };
  if (data.role !== expectedRole) return { ok: false, message: `This account is not a ${expectedRole.replace('_',' ')} login.` };

  saveSession({ id: data.id, name: data.name, username: data.username, role: data.role, department: data.department, mobile: data.mobile });
  return { ok: true, user: data };
}

// ---------- toast ----------
function toast(msg, isError = false) {
  let el = document.getElementById("psb-toast");
  if (!el) {
    el = document.createElement("div");
    el.id = "psb-toast";
    el.className = "toast";
    document.body.appendChild(el);
  }
  el.textContent = msg;
  el.className = "toast show" + (isError ? " error" : "");
  clearTimeout(window._toastTimer);
  window._toastTimer = setTimeout(() => el.classList.remove("show"), 3200);
}

const PERIODS = [
  { id: 1, label: "9:00 - 9:50 AM" },
  { id: 2, label: "9:50 - 10:40 AM" },
  { id: 3, label: "10:40 - 11:30 AM" },
  { id: 4, label: "11:40 - 12:30 PM" },
  { id: 5, label: "1:30 - 2:20 PM" },
  { id: 6, label: "2:20 - 3:10 PM" },
  { id: 7, label: "3:20 - 4:10 PM" },
];

function fmtDate(d) {
  return new Date(d + "T00:00:00").toLocaleDateString("en-IN", { day: "2-digit", month: "short", year: "numeric" });
}
